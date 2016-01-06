require "common_mark"

class ShardsController < ApplicationController
  property! :shards, :shard

  def before_action
    authenticate_user! if %w(new edit create destroy).includes?(action_name)
    load_and_authorize_shard if %w(edit destroy).includes?(action_name)
  end

  # TODO: pagination
  def index
    @shards = if letter = params["letter"]?
                Shard.where("name ILIKE ?", "#{ params["letter"][0] }%").order(:name).include_latest_version
              else
                Shard.order(:name).include_latest_version
              end
  end

  def search
    @shards = Shard.search(params["q"]).include_latest_version
  end

  def show
    @shard = Shard.find_by({ "name" => params["id"] })
  end

  def new
    @shard = Shard.new
  end

  def create
    repository = Repository.new((params["shard"] as Hash)["url"] as String)
    @shard = Shard.new(user_id: current_user.id, url: repository.url)

    spec = repository.spec("HEAD")
    shard.name = spec.name

    if shard.save
      DownloadShardVersionsJob.run(shard.id)
      redirect_to shard_url(shard)
    else
      render "new", status: 422
    end
  rescue ex : Repository::Error
    shard.errors.add(:url, "failed to access repository")
    render "new", status: 422
  end

  def refresh
    shard = current_user.shards.find_by({ name: params["id"] })
    DownloadShardVersionsJob.run(shard.id)
    session["flash"] = { "notice" => "Looking for new versions of #{ shard.name }." }.to_json
    redirect_to shard_url(shard)
  end

  def destroy
    shard.delete
    redirect_to shards_url
  end

  private def load_and_authorize_shard
    @shard = current_user.shards.find_by({ "name" => params["id"] })
  end

  private def shard_params(shard)
    (params["shard"] as Hash).each do |key, value|
      case key
      when "name" then shard.name = value as String
      end
    end

    shard
  end
end
