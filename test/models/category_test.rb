require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    assert_not Category.new(description: "Sin nombre").valid?
  end
end
