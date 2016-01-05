class Shard < Frost::Record
  belongs_to :user
  has_many :versions

  def self.search(q, context = self)
    context.where("shards.name LIKE ?", "#{ q }%")
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

  def self.already_registered?(url)
    where({ url: url }).count > 0
  end

  def repository
    @repository ||= Repository.new(url)
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
