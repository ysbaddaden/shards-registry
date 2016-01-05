require "../app/views/application_view"
require "../app/views/layouts_view"

require "../app/controllers/application_controller"
require "../app/controllers/api_controller"

require "../app/controllers/**"
require "../app/models/**"
require "../app/jobs/**"

module ShardRegistry
  {{ run "./routes.cr", "--codegen" }}
end

abstract class Frost::Controller
  include ShardRegistry::NamedRoutes
end

