require "../../test_helper"

class Api::ShardsControllerTest < Frost::Controller::Test
  def test_search
    get "/api/v1/shards/search?query=mini"
    assert_response 200

    shard_names = JSON.parse(response.body).as_a.map { |shard| (shard as Hash)["name"] }
    assert_equal ["minitest", "minigame"], shard_names
  end

  def test_show
    get "/api/v1/shards/pg"
    assert_response 200

    shard = JSON.parse(response.body).as_h
    assert_equal "pg", shard["name"]
  end

  def test_create
    attributes = {
      "url" => git_url(:awesome),
    }

    post "/api/v1/shards", attributes.to_json, {
      "Content-Type" => "application/json",
      "X-Api-Key" => users(:julien).api_key,
    }
    assert_response 201

    sleep 0.5 # wait for job

    shard = Shard.find_by({ name: "awesome" })
    assert_equal git_url(:awesome), shard.url
    assert_equal users(:julien), shard.user

    assert_equal ["1.0.0", "1.1.0", "1.1.1", "1.1.2", "1.2.0", "2.0.0", "2.1.0"],
      shard.versions.order(:number).pluck(:number)
  end

  def test_create_failure
    post "/api/v1/shards", "{}", {
      "Content-Type" => "application/json",
      "X-Api-Key" => users(:julien).api_key,
    }
    assert_response 422
  end

  def test_create_with_invalid_api_key
    post "/api/v1/shards", "{}", {
      "Content-Type" => "application/json",
      "X-Api-Key" => "invalid",
    }
    assert_response 401
  end

  def test_destroy
    delete "/api/v1/shards/webmock", { "X-Api-Key" => users(:ary).api_key }
    assert_response 204
    refute Shard.where({ name: "webmock" }).any?
  end

  def test_destroy_unknown_shard
    delete "/api/v1/shards/unknown", { "X-Api-Key" => users(:julien).api_key }
    assert_response 404
  end

  def test_destroy_with_unauthorized_api_key
    delete "/api/v1/shards/webmock", { "X-Api-Key" => users(:julien).api_key }
    assert_response 401
    assert Shard.where({ name: "webmock" }).any?
  end
end
