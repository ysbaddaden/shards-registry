require "../test_helper"

class UserTest < Minitest::Test
  def test_password
    assert users(:julien).valid_password?("secret")
    refute users(:julien).valid_password?("wrong")
  end

  def test_generates_api_key_on_create
    user = User.new(name: "jane", email: "jane@example.com")
    user.password = "battery horse"
    assert user.save
    assert user.api_key
  end

  def test_find_for_database_authentication
    assert_equal users(:julien), User.find_for_database_authentication("julien")
    assert_equal users(:julien), User.find_for_database_authentication("julien@example.com")
    assert_equal users(:ary), User.find_for_database_authentication("ary")
  end
end
