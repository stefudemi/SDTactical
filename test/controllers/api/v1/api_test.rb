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

  test "register creates a final user and returns a bearer token" do
    assert_difference("User.count") do
      post api_v1_register_path, params: {
        user: { name: "New Customer", email: "new@example.test", password: "password", password_confirmation: "password" }
      }
    end

    assert_response :created
    assert_equal "Bearer", response.parsed_body.fetch("token_type")
    assert_equal "new@example.test", response.parsed_body.dig("user", "email")
    assert_not User.find_by!(email: "new@example.test").admin?
  end

  test "register returns validation errors" do
    post api_v1_register_path, params: {
      user: { name: "Another Customer", email: @user.email, password: "password", password_confirmation: "password" }
    }

    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").present?
    assert response.parsed_body.fetch("errors").key?("email")
  end

  test "api accepts the configured frontend origin" do
    get api_v1_products_path, headers: { "Origin" => "http://localhost:5173" }

    assert_equal "http://localhost:5173", response.headers["Access-Control-Allow-Origin"]
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

  test "categories endpoint lists categories publicly" do
    get api_v1_categories_path

    assert_response :ok
    assert_equal Category.count, response.parsed_body.size
    assert_equal %w[description id name], response.parsed_body.first.keys.sort
  end

  test "products can be filtered by category and search term" do
    category = Category.create!(name: "Filtrada")
    match = Product.create!(name: "Mira Holográfica", description: "Óptica", price: 10, stock: 3, category: category)

    get api_v1_products_path, params: { category_id: category.id }
    assert_equal [ match.id ], response.parsed_body.map { |product| product["id"] }

    get api_v1_products_path, params: { q: "holográf" }
    assert_equal [ match.id ], response.parsed_body.map { |product| product["id"] }

    get api_v1_products_path, params: { q: "no-existe-xyz" }
    assert_response :ok
    assert_empty response.parsed_body
  end

  test "product show returns 404 for unknown id" do
    get api_v1_product_path(0)

    assert_response :not_found
    assert_equal "Producto no encontrado", response.parsed_body["error"]
  end

  test "login includes the user and rejects wrong credentials" do
    post api_v1_login_path, params: { email: @user.email, password: "password" }
    assert_equal @user.email, response.parsed_body.dig("user", "email")

    post api_v1_login_path, params: { email: @user.email, password: "incorrecta" }
    assert_response :unauthorized
    assert_equal "Email o contraseña inválidos", response.parsed_body["error"]
  end

  test "register validates password length and email format" do
    post api_v1_register_path, params: { user: { name: "X", email: "no-es-email", password: "123", password_confirmation: "123" } }

    assert_response :unprocessable_entity
    errors = response.parsed_body.fetch("errors")
    assert errors.key?("email")
    assert errors.key?("password")
  end

  test "profile can be updated and validates input" do
    token = login

    patch api_v1_profile_path, params: { user: { name: "Nuevo Nombre" } }, headers: bearer_headers(token)
    assert_response :ok
    assert_equal "Nuevo Nombre", response.parsed_body["name"]
    assert_equal "Nuevo Nombre", @user.reload.name

    patch api_v1_profile_path, params: { user: { name: "" } }, headers: bearer_headers(token)
    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").key?("name")

    patch api_v1_profile_path, params: { user: { name: "Otro" } }
    assert_response :unauthorized
  end

  test "orders require authentication" do
    get api_v1_orders_path
    assert_response :unauthorized
    post api_v1_orders_path, params: { order: { items: [] } }
    assert_response :unauthorized
  end

  test "order creation rejects insufficient stock" do
    product = products(:one)
    token = login

    post api_v1_orders_path,
      params: { order: { items: [ { product_id: product.id, quantity: product.stock + 1 } ] } },
      headers: bearer_headers(token)

    assert_response :unprocessable_entity
    assert_match(/Stock insuficiente/, response.parsed_body["error"])
  end

  test "lists only the current user's orders" do
    token = login
    product = products(:one)
    post api_v1_orders_path, params: { order: { items: [ { product_id: product.id, quantity: 1 } ] } }, headers: bearer_headers(token)

    get api_v1_orders_path, headers: bearer_headers(token)

    assert_response :ok
    assert_equal 1, response.parsed_body.size
    assert_equal @user.orders.first.id, response.parsed_body.first["id"]
  end

  test "cancelling a pending order restores stock" do
    product = products(:one)
    initial_stock = product.stock
    token = login
    post api_v1_orders_path, params: { order: { items: [ { product_id: product.id, quantity: 1 } ] } }, headers: bearer_headers(token)
    order_id = response.parsed_body.fetch("id")
    assert_equal initial_stock - 1, product.reload.stock

    post cancel_api_v1_order_path(order_id), headers: bearer_headers(token)

    assert_response :ok
    assert_equal "cancelled", response.parsed_body["status"]
    assert_equal initial_stock, product.reload.stock

    post cancel_api_v1_order_path(order_id), headers: bearer_headers(token)
    assert_response :unprocessable_entity
    assert_equal initial_stock, product.reload.stock
  end

  test "users cannot cancel another user's order" do
    token = login

    post cancel_api_v1_order_path(orders(:two)), headers: bearer_headers(token)

    assert_response :not_found
  end

  test "cors preflight allows PATCH from the frontend origin" do
    options api_v1_profile_path, headers: { "Origin" => "http://localhost:5173", "Access-Control-Request-Method" => "PATCH" }

    assert_response :no_content
    assert_includes response.headers["Access-Control-Allow-Methods"], "PATCH"
  end

  test "missing parameters and invalid JSON return a JSON 400" do
    post api_v1_register_path, params: {}.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
    assert response.parsed_body["error"].present?

    post api_v1_login_path, params: "{no es json", headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :bad_request
    assert_equal "application/json", response.media_type
  end

  test "validation errors are returned in Spanish" do
    post api_v1_register_path, params: { user: { name: "", email: "x", password: "1", password_confirmation: "2" } }

    errors = response.parsed_body.fetch("errors")
    assert_includes errors["name"], "no puede estar vacío"
    assert_includes errors["email"], "no es válido"
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
