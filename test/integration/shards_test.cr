require "./test_helper"

class ShardsIntegrationTest < Minitest::Test
  def test_lists_and_filters_shards
    page = ShardsPage.load
    assert_equal "/shards", page.uri.path
    assert_equal Shard.count, page.shards.size
    assert page.active_filter?("All")
  end
end
