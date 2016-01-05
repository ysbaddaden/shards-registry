class Version < Frost::Record
  belongs_to :shard

  def self.latest(context = self)
    context.order(:number).last?
  end

  def serializable_hash
    {
      version: number,
      released_at: released_at,
    }
  end
end
