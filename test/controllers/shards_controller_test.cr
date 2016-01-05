require "../test_helper"

class ShardsControllerTest < Frost::Controller::Test
  def test_index
    get "/shards"
    assert_response 200

    assert_select ".shards-list a", count: 4
    assert_select ".shards-list a", text: /minitest/
    assert_select ".shards-list a", text: /minigame/
    assert_select ".shards-list a", text: /pg/
    assert_select ".shards-list a", text: /webmock/
  end

  def test_index_starting_with_letter
    get "/shards?letter=w"
    assert_response 200, response.body

    refute_select ".shards-list a", text: "minitest"
    refute_select ".shards-list a", text: "minigame"
    refute_select ".shards-list a", text: "pg"
    assert_select ".shards-list a", text: "webmock"
  end

  def test_search
    get "/shards/search?q=mini"
    assert_response 200

    assert_select ".shards-list a", text: "minitest"
    assert_select ".shards-list a", text: "minigame"
    refute_select ".shards-list a", text: "pg"
    refute_select ".shards-list a", text: "webmock"
  end

  def test_show
    get "/shards/minitest"
    assert_response 200
    assert_select ".shard-versions li", count: 4
  end

  def test_new
    login users(:julien)
    get "/shards/new"
    assert_response 200
  end

  def test_create
    login users(:julien)

    post "/shards", "shard[url]=#{ git_url(:awesome) }"
    assert_redirected_to "http://test.host/shards/awesome"

    sleep 0.5 # wait for job

    shard = Shard.find_by({ name: "awesome" })
    assert_equal git_url(:awesome), shard.url
    assert_equal users(:julien), shard.user

    assert_equal ["1.0.0", "1.1.0", "1.1.1", "1.1.2", "1.2.0", "2.0.0", "2.1.0"],
      shard.versions.order(:number).pluck(:number)
  end

  def test_refresh
    shard = users(:julien).shards.create!({
      "name" => "fresh",
      "url" => git_url(:fresh),
    })
    create_git_release :fresh, "2.2.0"
    create_git_release :fresh, "2.3.0"

    login users(:julien)

    post "/shards/fresh/refresh"
    assert_redirected_to "http://test.host/shards/fresh"
    assert session["flash"]

    sleep 0.5 # wait for job

    assert_equal ["1.0.0", "1.1.0", "2.0.0", "2.1.0", "2.2.0", "2.3.0"],
      shard.versions.order(:number).pluck(:number)
  end

  def test_destroy
    login users(:julien)
    delete "/shards/minitest"
    assert_redirected_to "http://test.host/shards"
  end


  def test_anonymous_cant_new
    get "/shards/new"
    assert_redirected_to "http://test.host/users/session/new"
  end

  def test_anonymous_cant_create
    post "/shards", "shard[url]=git://example.com/test.git"
    assert_redirected_to "http://test.host/users/session/new"
  end

  def test_anonymous_cant_refresh
    post "/shards/minitest/refresh"
    assert_redirected_to "http://test.host/users/session/new"
  end

  def test_anonymous_cant_destroy
    delete "/shards/minitest"
    assert_redirected_to "http://test.host/users/session/new"
  end


  def test_only_owner_can_refresh
    login users(:ary)
    get "/shards/minitest/refresh"
    assert_response 404
  end

  def test_only_owner_can_destroy
    login users(:ary)
    delete "/shards/minitest"
    assert_response 404
  end
end
