require "http/client"
require "shards/spec"

class Repository
  class Error < Exception
  end

  enum Type
    Git
    GitHub
    Bitbucket

    def self.from_url(url)
      case url
      when %r(\Ahttps?://github\.com/)
        Type::GitHub
      when %r(\Ahttps?://bitbucket\.org/)
        Type::Bitbucket
      else
        Type::Git
      end
    end
  end

  getter :type, :url

  def initialize(@url)
    @type = Type.from_url(url)
  end

  def spec(refs)
    str = case type
          when Type::GitHub
            download "https://raw.githubusercontent.com/#{ repo }/#{ refs }/shard.yml"
          when Type::Bitbucket
            download "https://bitbucket.org/#{ repo }/raw/#{ refs }/shard.yml"
          else # Type::Git
            run "git archive --remote=#{ url.inspect } #{ refs.inspect } shard.yml | tar -xO"
          end
    Shards::Spec.from_yaml(str)
  end

  def repo
    $1 if url =~ %r(\Ahttps?://(?:github\.com|bitbucket\.org)/([^/]+?/[^/]+?)(?:\.git|)\Z)
  end

  private def run(command)
    Frost.logger.debug { "RUN #{ command }" }

    stdout = MemoryIO.new
    status = Process.run("/bin/sh", input: MemoryIO.new(command), output: stdout)

    if status.success?
      stdout.to_s
    else
      raise Error.new
    end
  end

  private def download(url)
    Frost.logger.debug { "DOWNLOAD #{ url }" }

    HTTP::Client.get(url) do |response|
      body = response.body_io.gets_to_end

      if response.status_code == 200
        body
      else
        raise Error.new(body)
      end
    end
  end
end
