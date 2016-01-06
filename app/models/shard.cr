class Shard < Frost::Record
  belongs_to :user
  has_many :versions

  def self.search(q, context = self)
    context.where("shards.name LIKE ?", "#{ q }%")
  end

  def self.already_registered?(url)
    where({ url: url }).count > 0
  end

  def self.include_latest_version(context = self)
    shard_ids = context.pluck(:id)

    if shard_ids.any?
      versions = Version
        .select("DISTINCT ON(shard_id) id, shard_id, number, description, released_at")
        .where({ shard_id: shard_ids })
        .order(:shard_id)
        .order(:released_at, :desc)

      versions.each do |version|
        if shard = context.to_a.find { |shard| shard.id == version.shard_id }
          shard.latest_version = version
        end
      end
    end

    context
  end

  def validate
    if name.blank?
      errors.add(:name, "name is required")
    elsif (name.to_s =~ /\A[a-zA-Z0-9_\-]+\Z/).nil?
      errors.add(:name, "name must only contain ASCII chars, digits, dashes or underscores")
    end

    if user.nil?
      errors.add(:user_id, "user is required")
    end

    if Shard.already_registered?(url)
      errors.add(:url, "already registered")
    end
  end

  def repository
    @repository ||= Repository.new(url)
  end

  def latest_version=(@latest_version : Version)
  end

  def latest_version
    @latest_version
  end

  def to_param
    name.to_s
  end

  def as_yaml_dependency
    String.build do |str|
      str << name << ":\n"

      case repository.type
      when Repository::Type::GitHub
        str << "  github: " << repository.repo << "\n"
      when Repository::Type::Bitbucket
        str << "  bitbucket: " << repository.repo << "\n"
      else # Repository::Type::Git
        str << "  git: " << repository.url << "\n"
      end
    end
  end

  def serializable_hash
    {
      name: name,
      url: url,
      #owner: user.name,
      #versions: versions.pluck(:number) as Array(String),
    }
  end
end
