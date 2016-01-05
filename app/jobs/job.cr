class Job
  class Error < Exception
  end

  macro def self.run(*args) : Nil
    spawn do
      begin
        new(*args).run
      rescue ex
        Frost.logger.warn { "DownloadShardVersionsJob failed: #{ ex.class.name }: #{ ex.message }" }
      ensure
        Frost::Record.release_connection
      end
    end

    nil
  end
end
