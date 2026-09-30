require "test_helper"

class Api::V1::ApiTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Customer", email: "api-customer@example.test", password: "password")
  end

  test "login returns a bearer token and profile excludes secrets" do
    post api_v1_login_path, params: { email: @user.email, password: "password" }

    assert_response :ok
    token = response.parsed_body.fetch("token")
    get api_v1_profile_path, headers: bearer_headers(token)

    assert_response :ok
    assert_equal @user.email, response.parsed_body.fetch("email")
    assert_not response.body.include?("password_digest")
    assert_not response.body.include?(token)
  end

  test "profile requires a valid token and logout invalidates it" do
    get api_v1_profile_path
    assert_response :unauthorized

    token = login
    delete api_v1_logout_path, headers: bearer_headers(token)
    assert_response :ok

    get api_v1_profile_path, headers: bearer_headers(token)
    assert_response :unauthorized
  end

  test "creates an order using server prices and decrements stock" do
    product = products(:one)
    initial_stock = product.stock
    token = login

    assert_difference("Order.count") do
      post api_v1_orders_path,
        params: { order: { items: [ { product_id: product.id, quantity: 1, unit_price: 0, total: 0 } ] } },
        headers: bearer_headers(token)
      assert_response :created, response.body
    end

    assert_response :created, response.body
    order = Order.order(:id).last
    assert_equal product.price, order.total
    assert_equal product.price, order.order_items.first.unit_price
    assert_equal initial_stock - 1, product.reload.stock
  end

  test "enqueues an order confirmation after successful creation" do
    product = products(:one)
    token = login

    assert_enqueued_with(job: OrderConfirmationJob) do
      post api_v1_orders_path,
        params: { order: { items: [ { product_id: product.id, quantity: 1 } ] } },
        headers: bearer_headers(token)
    end

    assert_response :created
  end

  test "failed order creation persists no partial order or stock changes" do
    product = products(:one)
    initial_stock = product.stock
    initial_order_items = OrderItem.count
    token = login

    assert_no_difference("Order.count") do
      post api_v1_orders_path,
        params: { order: { items: [
          { product_id: product.id, quantity: 1 },
          { product_id: 999_999, quantity: 1 }
        ] } },
        headers: bearer_headers(token)
    end

    assert_response :unprocessable_entity, response.body
    assert_equal initial_stock, product.reload.stock
    assert_equal initial_order_items, OrderItem.count
  end

  test "rejects malformed order items without persisting an order" do
    token = login

    assert_no_difference("Order.count") do
      post api_v1_orders_path,
        params: { order: { items: { product_id: products(:one).id, quantity: 1 } } },
        headers: bearer_headers(token)
    end

    assert_response :unprocessable_entity
  end

  test "users cannot access another user's order" do
    token = login
    order = orders(:two)

    get api_v1_order_path(order), headers: bearer_headers(token)

    assert_response :not_found
  end

  test "product endpoints return JSON without password or token fields" do
    get api_v1_products_path

    assert_response :ok
    assert_equal "application/json", response.media_type
    assert_not response.body.include?("password_digest")
    assert_not response.body.include?("api_token")
  end

  private

  def login
    post api_v1_login_path, params: { email: @user.email, password: "password" }
    response.parsed_body.fetch("token")
  end

  def bearer_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
