require "./job"
require "shards/resolvers/git"

class DownloadShardVersionsJob < Job
  getter :shard

  def initialize(shard_id)
    @shard = Shard.find(shard_id)
  end

  def run
    clone_or_update_repository

    unknown_versions.each do |version|
      number, released_at = version

      if spec = find_spec(number)
        version = Version.new(
          shard_id: shard.id,
          number: number,
          released_at: released_at,
          description: spec.description,
          license: spec.license,
          readme: find_readme(number)
        )
        version.save
      end
    end
  end

  private def find_spec(version)
    contents = execute("git show v#{ version }:shard.yml")
    Shards::Spec.from_yaml(contents)
  rescue Job::Error
  end

  private def find_readme(version)
    execute("git show v#{ version }:README.md")
  rescue Job::Error
  end

  private def unknown_versions
    known_versions = shard.versions.pluck(:number)
    find_versions.reject { |version| known_versions.includes?(version[0]) }
  end

  private def find_versions
    execute("git log --tags --simplify-by-decoration --pretty=\"%ai %d\"")
      .split('\n')
      .compact_map { |line| {$2, $1} if line =~ /\A(.+?)\s+\(.*?tag: v([^,]+).*?\)/ }
  end

  private def clone_or_update_repository
    if Dir.exists?(cache_path)
      execute("git fetch --all --quiet")
    else
      parent_path = File.dirname(cache_path)
      Dir.mkdir_p(parent_path)
      execute("git clone --mirror --quiet -- #{ shard.url.inspect } #{ shard.name }", path: parent_path)
    end
  end

  private def cache_path
    @cache_path ||= File.join(Frost.config.cache_path, shard.name.to_s)
  end

  private def execute(command, path = cache_path)
    Frost.logger.debug(command)

    stdin = MemoryIO.new(command)
    stdout = MemoryIO.new
    stderr = MemoryIO.new
    status = Process.run("/bin/sh", input: stdin, output: stdout, error: stderr, chdir: path)

    if status.success?
      stdout.to_s
    else
      raise Job::Error.new(stderr.to_s.split('\n').first)
    end
  end
end
