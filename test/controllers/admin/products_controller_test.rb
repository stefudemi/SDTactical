require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = User.create!(name: "Admin", email: "products-admin@example.test", password: "password", admin: true)
    post login_path, params: { email: admin.email, password: "password" }
  end

  test "should get index" do
    get admin_products_path
    assert_response :success
  end

  test "should get show" do
    get admin_product_path(products(:one))
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_path
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_product_path(products(:one))
    assert_response :success
  end
end
