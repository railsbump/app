require_relative '../lib/gemfile_parser'

test 'scans gems from gemfile' do |gemfile|
  gemfile = <<EOS
source "https://rubygems.org"

ruby "2.0.0"

gem "rails", "4.0.0"
gem 'pg', "1.0.0"
gem "puma", '2.0.0'
gem 'coffee-rails'
EOS

  expected = ['rails', 'pg', 'puma', 'coffee-rails']

  assert_equal expected, GemfileParser.new(gemfile).gems
end
