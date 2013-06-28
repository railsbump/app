require "test_helper"

class GemfileParserTest < ActiveSupport::TestCase
  GEMFILE = File.read File.expand_path("../fixtures/gemfile", __dir__)

  test "returns gems status for a given Gemfile" do
    gems   = Rubygem.all
    result = GemfileParser.gems_status GEMFILE

    assert_equal gems, result
  end
end
