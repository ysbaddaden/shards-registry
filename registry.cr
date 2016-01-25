require "frost/server"
require "./config/bootstrap"

module ShardRegistry
  class Server < Frost::Server
    #DEFLATE_MIME_TYPES = %w(
    #  text/html
    #  text/plain
    #  text/xml
    #  text/css
    #  text/javascript
    #  application/javascript
    #  application/json
    #  image/svg+xml
    #)

    def handlers
      [
        Frost::Server::LogHandler.new,
        Frost::Server::HttpsEverywhereHandler.new,
        HTTP::DeflateHandler.new,
        Frost::Server::PublicFileHandler.new(File.join(Frost.root, "public"))
      ]
    end

    def dispatcher
      @dispatcher ||= ShardRegistry::Dispatcher.new
    end
  end

  Server.run
end
