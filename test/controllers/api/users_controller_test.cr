require "../../test_helper"

class Api::UsersControllerTest < Frost::Controller::Test
  def test_api_key
    get "/api/users/api_key", userinfo: "julien:secret"
    assert_response 200
    assert_equal({ "api_key" => users(:julien).api_key }, JSON.parse(response.body).raw)
  end

  def test_api_key_with_unknown_user
    get "/api/users/api_key", userinfo: "nobody:secret"
    assert_response 401
    assert_empty response.body
  end

  def test_api_key_with_wrong_password
    get "/api/users/api_key", userinfo: "julien:wrong"
    assert_response 401
    assert_empty response.body
  end

  def test_create
    attributes = {
      name: "nick",
      email: "nick@example.com",
      password: "super-secret"
    }

    post "/api/users", attributes.to_json, { "Content-Type" => "application/json" }
    assert_response 201
    assert_empty response.body

    user = User.find_by({ name: "nick" })
    assert_equal "nick@example.com", user.email
    assert user.valid_password?("super-secret")
  end

  def test_create_failure
    post "/api/users", "{}", { "Content-Type" => "application/json" }
    assert_response 422
    assert_equal "application/json", response.headers["Content-Type"]

    assert errors = JSON.parse(response.body).as_a
    assert_includes errors, "name is required"
    assert_includes errors, "email is required"
    assert_includes errors, "password is required"
  end

  def test_update
    attributes = {
      name: "julian",
      email: "julian@example.com",
      password: "changed",
    }

    patch "/api/users/#{users(:julien).id}?api_key=#{users(:julien).api_key}",
      attributes.to_json, { "Content-Type" => "application/json" }

    assert_response 200
    assert_empty response.body

    user = User.find_by({ name: "julian" })
    assert_equal users(:julien).id, user.id
    assert_equal "julian@example.com", user.email
    assert user.valid_password?("changed")
  end

  def test_update_with_unauthorized_api_key
    patch "/api/users/#{users(:julien).id}?api_key=#{users(:ary).api_key}",
      "{}", { "Content-Type" => "application/json" }

    assert_response 401
    assert_empty response.body
  end

  def test_update_failure
    attributes = { name: "", email: "", password: "" }

    patch "/api/users/#{users(:julien).id}?api_key=#{users(:julien).api_key}",
      attributes.to_json, { "Content-Type" => "application/json" }

    assert_response 422, response.body
    assert_equal "application/json", response.headers["Content-Type"]

    assert errors = JSON.parse(response.body).as_a
    assert_includes errors, "name is required"
    assert_includes errors, "email is required"
    #assert_includes errors, "password is required"
  end
end
