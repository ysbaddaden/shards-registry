class ShardsPage < Selenium::PageObject
  def get
    session.url = "http://localhost:9393/shards"
  end

  def shards
    session.find_element(:css, ".shards-list a")
  end

  def filters
    session.find_elements(:css, ".filter-letter a")
  end

  def filter(filter)
    filter = filter.upcase if filter.size == 1
    filters.find_element(:link_text, filter)
  end

  def active_filter
    session.find_element(:css, ".filter-letter .active a")
  end

  def active_filter?(filter)
    filter = filter.upcase if filter.size == 1
    active_filter.text.strip == filter
  end
end
