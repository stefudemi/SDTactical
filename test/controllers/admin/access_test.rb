require "test_helper"

class Admin::AccessTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitors to login" do
    get admin_root_path

    assert_redirected_to login_path
  end

  test "denies non-admin users" do
    user = User.create!(name: "Customer", email: "customer@example.test", password: "password")
    post login_path, params: { email: user.email, password: "password" }

    get admin_root_path

    assert_redirected_to root_path
  end

  test "allows an admin to sign in and access the back office" do
    admin = User.create!(name: "Admin", email: "admin@example.test", password: "password", admin: true)
    post login_path, params: { email: admin.email, password: "password" }

    get admin_root_path

    assert_response :success
  end
end
