require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires a unique email" do
    assert_not User.new(name: "Sin email", password: "password").valid?

    duplicate = User.new(name: "Duplicado", email: users(:one).email, password: "password")
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :email
  end

  test "requires name, a valid email and a password of at least 6 characters" do
    user = User.new(name: "", email: "no-es-email", password: "123")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :name
    assert_includes user.errors.attribute_names, :email
    assert_includes user.errors.attribute_names, :password
    assert User.new(name: "Ana", email: "ANA@demo.test", password: "secret1").valid?
  end

  test "normalizes email to lowercase" do
    user = User.create!(name: "Ana", email: " ANA@Demo.Test ", password: "secret1")

    assert_equal "ana@demo.test", user.email
  end
end
