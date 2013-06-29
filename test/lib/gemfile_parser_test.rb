require "minitest/autorun"
require_relative "../../lib/gemfile_parser"

class GemfileParserTest < ActiveSupport::TestCase
  GEMFILE  = File.read File.expand_path("../fixtures/gemfile", __dir__)
  EXCLUDED = GemfileParser::EXCLUDED

  test "returns gems status for a given Gemfile" do
    gems   = ["dalli", "pg", "puma"] # meh
    result = GemfileParser.gem_names GEMFILE

    assert_equal gems, result
    assert !gems.any? { |g| EXCLUDED.include? g }
  end
end
