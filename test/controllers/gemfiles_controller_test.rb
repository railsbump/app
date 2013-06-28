require "test_helper"

class GemfilesControllerTest < ActionController::TestCase
  GEMFILE = File.read File.expand_path("../fixtures/gemfile", __dir__)

  test "#create returns existing gems from Gemfile" do
    post :create, gemfile: GEMFILE

    assert_equal Rubygem.all, assigns(:gems)
  end
end
