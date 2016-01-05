require "../../test_helper"

class Api::WebhooksControllerTest < Frost::Controller::Test
  def test_github_ping
    post_github :ping, shards(:minitest)
    assert_response 200
  end

  def test_github_create
    shard = create_shard("github_1")

    post_github :create, shard
    assert_response 200

    sleep 0.5
    assert_equal ["1.0.0", "1.2.0", "2.0.0"], shard.versions.pluck(:number)
  end

  def test_github_delete
    skip "TODO: delete shard versions of deleted version tags"
  end

  def test_github_identifies_shard_by_clone_url
    shard = create_shard("github_2")

    post_github :create, shard, data: {
      repository: { git_url: git_url("github_2"), clone_url: "" }
    }
    assert_response 200

    sleep 0.5
    assert_equal ["1.0.0", "1.2.0", "2.0.0"], shard.versions.pluck(:number)
  end

  def test_github_fails_to_identify_user
    post_github :create, shards(:webmock), api_key: "invalid"
    assert_response 401
  end

  def test_github_fails_to_identify_user_shard
    post_github :create, shards(:webmock)
    assert_response 404
  end

  def test_github_silently_skips_unsupported_event
    post_github :desployment, shards(:webmock), data: { deployment: { id: "123" } }
    assert_response 200
  end

  private def create_shard(name)
    shard = users(:julien).shards.create!({
      "name" => name,
      "url" => git_url(name)
    })
    create_git_repository name, "1.0.0", "1.2.0", "2.0.0"
    shard
  end

  private def post_github(event, shard, api_key = users(:julien).api_key, data = nil)
    headers = {
      "X-Github-Event": event.to_s,
      "Content-Type" => "application/json"
    }

    body = {} of Symbol => String | Hash(Symbol, String)

    unless event == :ping
      body[:repository] = { git_url: git_url(shard.name), clone_url: "" }
    end

    if %i(create delete).includes?(event)
      body[:ref] = "v2.0.0"
      body[:ref_type] = "tag"
    end

    if data
      body.merge!(data)
    end

    post "/api/webhooks/github?api_key=#{ api_key }", body.to_json, headers
  end
end
