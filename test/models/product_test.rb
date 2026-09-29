require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "rejects negative prices and stock" do
    product = Product.new(name: "Validación", category: categories(:one), price: -1, stock: -1)

    assert_not product.valid?
    assert_includes product.errors.attribute_names, :price
    assert_includes product.errors.attribute_names, :stock
  end

  test "requires a name" do
    product = Product.new(category: categories(:one), price: 0, stock: 0)

    assert_not product.valid?
    assert_includes product.errors.attribute_names, :name
  end

  test "rejects fractional stock before integer casting" do
    product = Product.new(name: "Fraccional", category: categories(:one), price: 0, stock: "1.5")

    assert_not product.valid?
    assert_includes product.errors.attribute_names, :stock
  end

  test "requires price and stock values" do
    product = Product.new(name: "Sin datos numéricos", category: categories(:one))

    assert_not product.valid?
    assert_includes product.errors.attribute_names, :price
    assert_includes product.errors.attribute_names, :stock
  end
end
