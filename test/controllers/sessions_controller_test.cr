require "../test_helper"

class ShardsControllerTest < Frost::Controller::Test
  def test_new
    get "/users/session/new"
    assert_response 200

    assert_select "form[action='/users/session'][method=post]"
    assert_select "input[type=text][name='user[name]']"
    assert_select "input[type=password][name='user[password]']"
  end

  def test_create
    post "/users/session", "user[name]=julien&user[password]=secret"
    assert_redirected_to "http://test.host/users/julien"
    assert_equal users(:julien).id.to_s, session["user_id"]
  end

  def test_create_failure
    post "/users/session", "user[name]=julien&user[password]=wrong"
    assert_response 401
    assert_select "form[action='/users/session'][method=post]"
    assert_nil session["user_id"]?
  end

  def test_destroy
    login users(:julien)

    delete "/users/session"
    assert_redirected_to "http://test.host/shards"
    assert_nil session["user_id"]?
  end
end
