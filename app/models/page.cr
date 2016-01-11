class Page
  property :name

  def initialize(@name)
  end

  def body
    @body ||= File.read(path)
  end

  def exists?
    File.exists?(path)
  end

  def path
    File.join(self.class.guides_path, "#{ name }.md")
  end

  def self.find(name)
    page = Page.new(name)
    raise Frost::Record::RecordNotFound.new("no such page: #{ name }") unless page.exists?
    page
  end

  def self.guides_path
    File.join(Frost.root, "guides")
  end
end
