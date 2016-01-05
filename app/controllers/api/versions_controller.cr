module Api
  class VersionsController < ApiController
    getter! :shard

    def before_action
      @shard = Shard.find_by({ name: params["shard_id"] })
    end

    def index
      versions = shard.versions.order(:number, :desc)
      render text: versions.to_json
    end

    def latest
      if version = shard.versions.latest
        render text: version.to_json
      else
        head 404
      end
    end
  end
end
