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

    class DisableKeepAliveHandler < HTTP::Handler
      def call(context)
        context.response.headers["Connection"] = "close"
        call_next(context)
      end
    end

    def handlers
      [
        Frost::Server::LogHandler.new,
        Frost::Server::HttpsEverywhereHandler.new,
        DisableKeepAliveHandler.new,
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
