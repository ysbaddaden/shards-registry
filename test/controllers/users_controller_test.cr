require "../test_helper"

class ShardsControllerTest < Frost::Controller::Test
  def test_show
    get "/users/julien"
    assert_response 200

    assert_select "ul > li > a[href='/shards/minitest']"
    assert_select "ul > li > a[href='/shards/minigame']"
    refute_select "ul > li > a[href='/shards/webmock']"
  end

  def test_new
    get "/users/new"
    assert_response 200

    assert_select "form[action='/users'][method=post]"
    assert_select "input[type=text][name='user[name]']"
    assert_select "input[type=email][name='user[email]']"
    assert_select "input[type=password][name='user[password]']"
  end

  def test_edit
    login users(:julien)

    get "/users/julien/edit"
    assert_response 200

    assert_select "form[action='/users/julien'][method=post] input[name=_method][value=patch]"
    assert_select "input[type=text][name='user[name]']"
    assert_select "input[type=email][name='user[email]']"
    assert_select "input[type=password][name='user[password]']"
  end

  def test_create
    post "/users", "user[name]=ysbaddaden&user[email]=ysbaddaden@example.com&user[password]=sekret"
    assert_redirected_to "http://test.host/users/ysbaddaden"
    assert user = User.find_by({ name: "ysbaddaden" })
    assert user.valid_password?("sekret")
  end

  def test_update
    login users(:julien)

    patch "/users/julien", "user[password]=incredible"
    assert_redirected_to "http://test.host/users/julien"
    assert User.find(users(:julien).id).valid_password?("incredible")
  end

  def test_reset_api_key
    login users(:julien)
    api_key = users(:julien).api_key

    post "/users/julien/api_key/reset"
    assert_redirected_to "http://test.host/users/julien"

    assert session["flash"]
    refute_equal api_key, User.find(users(:julien).id).api_key
  end

  def test_destroy
    login users(:julien)

    delete "/users/julien"
    assert_redirected_to "http://test.host/shards"
    refute User.find_by?({ name: "julien" })
  end
end
