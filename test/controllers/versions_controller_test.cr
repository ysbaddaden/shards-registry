require "../test_helper"

class VersionsControllerTest < Frost::Controller::Test
  def test_index
    get "/shards/minitest/versions"
    assert_response 200

    shards(:minitest).versions.each do |version|
      assert_select "ul strong", text: version.number
    end
  end
end
