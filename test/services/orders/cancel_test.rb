require "test_helper"

class Orders::CancelTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Cliente", email: "cancel@example.test", password: "password")
    @product = products(:one)
  end

  test "cancels a pending order and restores stock" do
    order = Orders::Create.new(user: @user, items: [ { "product_id" => @product.id, "quantity" => 1 } ]).call
    assert_equal 0, @product.reload.stock

    Orders::Cancel.new(order: order).call

    assert_equal "cancelled", order.reload.status
    assert_equal 1, @product.reload.stock
  end

  test "refuses to cancel an order that is not pending" do
    order = Orders::Create.new(user: @user, items: [ { "product_id" => @product.id, "quantity" => 1 } ]).call
    order.update!(status: "shipped")

    assert_raises(Orders::Cancel::NotCancellable) { Orders::Cancel.new(order: order).call }
    assert_equal 0, @product.reload.stock
  end
end
