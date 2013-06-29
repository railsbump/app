require "minitest/autorun"
require_relative "../../lib/gemfile_parser"

class GemfileParserTest < ActiveSupport::TestCase
  GEMFILE  = File.read File.expand_path("../fixtures/gemfile", __dir__)
  EXCLUDED = GemfileParser::EXCLUDED

  test "returns gems status for a given Gemfile" do
    gems   = Rubygem.alphabetical # meh
    result = GemfileParser.gems_status GEMFILE

    assert_equal gems.to_a, result
    assert_equal EXCLUDED, EXCLUDED - gems.pluck(:name)
  end
end
