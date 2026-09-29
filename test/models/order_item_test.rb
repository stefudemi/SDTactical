require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "requires a positive integer quantity" do
    item = OrderItem.new(order: orders(:one), product: products(:one), quantity: 0, unit_price: 0)

    assert_not item.valid?
    assert_includes item.errors.attribute_names, :quantity
  end

  test "rejects fractional quantity before integer casting" do
    item = OrderItem.new(order: orders(:one), product: products(:one), quantity: "1.5", unit_price: 0)

    assert_not item.valid?
    assert_includes item.errors.attribute_names, :quantity
  end

  test "requires quantity and unit price" do
    item = OrderItem.new(order: orders(:one), product: products(:one))

    assert_not item.valid?
    assert_includes item.errors.attribute_names, :quantity
    assert_includes item.errors.attribute_names, :unit_price
  end
end
