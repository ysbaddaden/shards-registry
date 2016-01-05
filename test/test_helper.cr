ENV["FROST_ENV"] ||= "test"

require "../config/bootstrap"
require "frost/minitest"
require "./support/*"

Frost.config.cache_path += "/test"

class Minitest::Test
  fixtures "#{ __DIR__ }/fixtures"
end

class ApplicationController
  def session_store
    Frost::Controller::Session::TestStore
  end
end

class Frost::Controller::Test
  def dispatcher
    @dispatcher ||= ShardRegistry::Dispatcher.new
  end

  def login(user)
    session["user_id"] = user.id.to_s
  end

  def logout
    session.delete("user_id") if @session
  end
end
