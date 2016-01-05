module Api
  class WebhooksController < ApiController
    def before_action
      authenticate_user!
    end

    def github
      event = request.headers["X-Github-Event"]

      unless %w(create delete).includes?(event)
        return head 200
      end

      payload = JSON.parse(request.body.to_s)

      unless payload["ref_type"].as_s == "tag"
        return head 200
      end

      git_url = payload["repository"]["git_url"].as_s
      clone_url = payload["repository"]["clone_url"].as_s

      unless shard = current_user.shards.find_by?({ url: [git_url, clone_url] })
        return head 404
      end

      DownloadShardVersionsJob.run(shard.id)
      head 200
    end
  end
end
