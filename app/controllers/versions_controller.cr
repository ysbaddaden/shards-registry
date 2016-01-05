class VersionsController < ApplicationController
  property! :shard, :versions

  def before_action
    load_shard
  end

  def index
    @versions = shard.versions.order(:number, :desc)
  end

  private def load_shard
    @shard = Shard.find_by({ name: params["shard_id"] })
  end
end
