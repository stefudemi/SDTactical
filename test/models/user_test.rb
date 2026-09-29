require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires a unique email" do
    assert_not User.new(name: "Sin email", password: "password").valid?

    duplicate = User.new(name: "Duplicado", email: users(:one).email, password: "password")
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :email
  end
end
