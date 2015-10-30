require "minitest/autorun"
require_relative "../../lib/gemfile_parser"

class GemfileParserTest < ActiveSupport::TestCase
  EXCLUDED = GemfileParser::EXCLUDED

  test "returns gems status for a given Gemfile" do
    gems = Rubygem.by_name
    gemfile = File.read File.expand_path("../fixtures/gemfile", __dir__)
    registered, unregistered = GemfileParser.gems_status gemfile

    assert_equal gems.to_a, registered
    assert_equal ["coffee-rails"], unregistered
    assert_equal EXCLUDED, EXCLUDED - registered.pluck(:name)
  end

  test "ignores gems on commented lines" do
    gemfile = File.read File.expand_path("../fixtures/gemfile_with_commented_gem", __dir__)
    registered, unregistered = GemfileParser.gems_status gemfile

    assert !registered.include?("kaminari")
    assert !unregistered.include?("kaminari")
    assert !registered.include?("coffee-rails")
    assert !unregistered.include?("coffee-rails")
  end
end
