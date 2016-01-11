require "crypto/subtle"
require "openssl/hmac"
require "frost/support/slice"

module Api
  class WebhooksController < ApiController
    def github
      event = request.headers["X-Github-Event"]
      return head 204 unless %w(ping create delete).includes?(event)

      body = request.body.to_s
      payload = JSON.parse(body)
      git_url = payload["repository"]["git_url"].as_s
      clone_url = payload["repository"]["clone_url"].as_s

      return head 404 unless shard = Shard.find_by?({ url: [git_url, clone_url] })
      return head 401 unless valid_github_signature?(request, body, shard.user.api_key)

      DownloadShardVersionsJob.run(shard.id) unless event == "ping"
      head 204
    end

    private def valid_github_signature?(request, body, api_key)
      # header is sha1=digest
      signature = request.headers["X-Hub-Signature"].split("=").last
      digest = OpenSSL::HMAC.hexdigest(:sha1, api_key.to_s.to_slice, body)
      Crypto::Subtle.constant_time_compare(digest.to_slice, signature.to_slice) == 1
    end
  end
end
