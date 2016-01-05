require "./factories"

module ShardRegistry
  module Fixtures
    def before_setup
      super

      unless @@created_repositories
        run "rm -rf #{tmp_path}/*"
        setup_repositories
      end

      run "rm -rf #{Frost.config.cache_path}/*"
    end

    def setup_repositories
      create_git_repository "awesome", "1.0.0", "1.1.0", "1.1.1", "1.1.2", "1.2.0", "2.0.0", "2.1.0"
      create_git_repository "fresh", "1.0.0", "1.1.0", "2.0.0", "2.1.0"
      @@created_repositories = true
    end
  end
end

class Minitest::Test
  include ShardRegistry::Fixtures
end
