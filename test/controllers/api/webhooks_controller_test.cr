require "../../test_helper"
require "openssl/hmac"
require "frost/support/slice"

module Api::WebhooksControllerTest
  class GithubTest < Frost::Controller::Test
    def test_ping
      shard = create_shard("ping")
      post_github :ping, shard
      assert_response 204
    end

    def test_create
      shard = create_shard("create")
      post_github :create, shard
      assert_response 204

      sleep 0.5
      assert_equal ["1.0.0", "1.2.0", "2.0.0"], shard.versions.pluck(:number)
    end

    def test_delete
      skip "TODO: delete shard versions of deleted version tags"
    end

    def test_identifies_shard_by_clone_url
      shard = create_shard("clone")

      post_github :create, shard, data: {
        repository: { git_url: git_url("clone"), clone_url: "" }
      }
      assert_response 204

      sleep 0.5
      assert_equal ["1.0.0", "1.2.0", "2.0.0"], shard.versions.pluck(:number)
    end

    def test_fails_to_authorize_request
      shard = create_shard("invalid")
      post_github :create, shard, api_key: "invalid"
      assert_response 401
    end

    def test_silently_skips_unsupported_event
      shard = create_shard("deployment")
      post_github :deployment, shard, data: { deployment: { id: "123" } }
      assert_response 204
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
      body[:repository] = {
        git_url: git_url(shard.name),
        clone_url: ""
      }

      if %i(create delete).includes?(event)
        body[:ref] = "v2.0.0"
        body[:ref_type] = "tag"
      end

      if data
        body.merge!(data)
      end

      body = body.to_json

      if api_key
        headers["X-Hub-Signature"] = "sha1=#{ OpenSSL::HMAC.hexdigest(:sha1, api_key.to_slice, body) }"
      end

      post "/api/webhooks/github", body, headers
    end
  end
end
