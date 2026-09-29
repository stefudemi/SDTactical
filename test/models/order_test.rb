require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "defaults to pending with a zero total" do
    order = Order.new(user: users(:one))

    assert order.valid?
    assert_equal "pending", order.status
    assert_equal 0, order.total
  end

  test "rejects unsupported statuses" do
    order = Order.new(user: users(:one), status: "unknown", total: 0)

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :status
  end
end
