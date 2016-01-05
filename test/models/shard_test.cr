require "../test_helper"

class ShardTest < Minitest::Test
  def test_versions
    assert_equal ["0.1.0", "0.1.1", "0.1.2", "0.1.3"],
      shards(:minitest).versions.order(:number).pluck(:number)

    assert_equal "0.1.3", shards(:minitest).versions.latest.try(&.number)
    assert_equal "0.3.2", shards(:pg).versions.latest.try(&.number)
  end

  def test_search
    assert_equal [shards(:minitest), shards(:minigame)], Shard.search("mini").to_a
    assert_equal [shards(:webmock)], Shard.search("web").to_a
  end
end
