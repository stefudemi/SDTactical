require "test_helper"

class Admin::ManagementTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin", email: "manager@example.test", password: "password", admin: true)
    post login_path, params: { email: @admin.email, password: "password" }
  end

  test "creates a category" do
    assert_difference("Category.count") do
      post admin_categories_path, params: { category: { name: "Equipo", description: "Accesorios" } }
    end

    assert_redirected_to admin_category_path(Category.order(:id).last)
  end

  test "order updates only accept status" do
    order = orders(:one)
    original_total = order.total
    original_user_id = order.user_id

    patch admin_order_path(order), params: {
      order: { status: "confirmed", total: 0, user_id: users(:two).id }
    }

    assert_redirected_to admin_order_path(order)
    assert_equal "confirmed", order.reload.status
    assert_equal original_total, order.total
    assert_equal original_user_id, order.user_id
  end
end
