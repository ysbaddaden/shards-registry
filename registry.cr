require "option_parser"
require "http/server"
require "frost/server/handlers/log_handler"
require "frost/server/handlers/public_file_handler"
require "frost/server/handlers/deflate_handler"
require "frost/server/handlers/https_everywhere_handler"
require "./config/bootstrap"

host = "localhost"
port = 9292

opts = OptionParser.new
opts.on("-b HOST", "--bind=HOST", "Bind to host (defaults to localhost)") { |value| host = value }
opts.on("-p PORT", "--port=PORT", "Bind to port (defaults to 9292)") { |value| port = value.to_i }
opts.on("-h",      "--help",      "Show this help") { puts opts; exit }

begin
  opts.parse(ARGV)
rescue ex : OptionParser::InvalidOption
  STDERR.puts ex.message
  STDERR.puts
  STDERR.puts "Available options:"
  STDERR.puts opts
  exit
end

spawn do
  handlers = [
    Frost::Server::LogHandler.new,
    #Frost::Server::HttpsEverywhereHandler.new,
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

  server = HTTP::Server.new(host, port, handlers) do |request|
    dispatcher.call(request)
  end

  puts "Listening on http://#{ host }:#{ port }"
  server.listen
end

sleep
