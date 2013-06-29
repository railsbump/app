require "test_helper"

class GemfilesControllerTest < ActionController::TestCase
  test "#create returns existing gems from Gemfile" do
    gemfile, parsed, gems = "gemfile", stub, stub
    GemfileParser.expects(:gems).with(gemfile).returns parsed
    Rubygem.expects(:where).with(name: parsed).returns gems

    post :create, gemfile: gemfile

    assert_equal gems, assigns(:gems)
  end
end
