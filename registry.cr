require "http/server"
require "frost/server/handlers/log_handler"
require "frost/server/handlers/public_file_handler"
require "frost/server/handlers/deflate_handler"
require "./config/bootstrap"

spawn do
  port = ENV.fetch("PORT", "9292").to_i

  handlers = [
    Frost::Server::LogHandler.new,
    HTTP::DeflateHandler.new(%w(
      text/html
      text/plain
      text/xml
      text/css
      text/javascript
      application/javascript
      application/json
      image/svg+xml
    )),
    Frost::Server::PublicFileHandler.new(File.join(Frost.root, "public"))
  ]
  dispatcher = ShardRegistry::Dispatcher.new

  server = HTTP::Server.new("0.0.0.0", port, handlers) do |request|
    dispatcher.call(request)
  end

  puts "Listening on http://0.0.0.0:#{ port }"
  server.listen
end

sleep
