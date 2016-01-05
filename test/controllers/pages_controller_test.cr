require "../test_helper"

class PagesControllerTest < Frost::Controller::Test
  def test_landing
    get "/"
    assert_redirected_to "http://test.host/shards"
  end
end
