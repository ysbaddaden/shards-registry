module Api
  class ShardsController < ApiController
    def before_action
      authenticate_user! if %w(create destroy).includes?(action_name)
    end

    def search
      shards = Shard.search(params["query"]).limit(50).to_a
      render text: shards.to_json
    end

    def show
      shard = Shard.find_by({ name: params["id"] })
      render text: shard.to_json
    rescue Frost::Record::RecordNotFound
      head 404
    end

    def create
      data = JSON.parse(request.body.to_s)

      unless url = data["url"]?
        render text: ["repository url is required"].to_json, status: 422
        return
      end

      repository = Repository.new(url.to_s)
      shard = Shard.new(user_id: current_user.id, url: repository.url)

      spec = repository.spec("HEAD")
      shard.name = spec.name

      if shard.save
        DownloadShardVersionsJob.run(shard.id)
        render text: shard.to_json, status: 201
      else
        render text: shard.errors.to_json, status: 422
      end
    end

    def destroy
      shard = Shard.find_by({ name: params["id"] })
      return unless authorize!(shard)
      shard.destroy
      head 204
    rescue Frost::Record::RecordNotFound
      head 404
    end
  end
end
