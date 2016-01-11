require "../../test_helper"

class Api::VersionsControllerTest < Frost::Controller::Test
  def test_index
    get "/api/v1/shards/minitest/versions"
    assert_response 200

    numbers = JSON.parse(response.body).as_a.map do |version|
      (version as Hash)["version"]
    end
    assert_equal ["0.1.3", "0.1.2", "0.1.1", "0.1.0"], numbers
  end

  def test_latest
    get "/api/v1/shards/minitest/versions/latest"
    assert_response 200
    assert_equal "0.1.3", JSON.parse(response.body)["version"].as_s
  end
end
