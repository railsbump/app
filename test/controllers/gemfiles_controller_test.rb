require "test_helper"

class GemfileChecksControllerTest < ActionController::TestCase
  test "#create returns existing gems from Gemfile" do
    gemfile, gems = "gemfile", stub("gems")
    GemfileParser.expects(:gems_status).with(gemfile).returns gems

    post :create, gemfile: gemfile

    assert_equal gems, assigns(:gems)
  end
end
