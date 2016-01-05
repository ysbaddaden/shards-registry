require "../config/bootstrap"
require "../app/jobs/download_shard_versions_job"

unless name = ARGV[0]?
  puts "Syntax: crystal bin/update.cr -- <shard name>"
  exit 1
end

shard = Shard.find_by({ name: name })
job = DownloadShardVersionsJob.new(shard.id)
job.run
