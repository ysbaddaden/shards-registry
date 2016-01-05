class PagesController < ApplicationController
  def landing
    redirect_to shards_url
  end
end
