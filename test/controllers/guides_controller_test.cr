require "../test_helper"

class GuidesControllerTest < Frost::Controller::Test
  def test_index
    get "/guides/api"
    assert_response 200
  end
end
