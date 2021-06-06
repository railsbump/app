# frozen_string_literal: true

source 'https://rubygems.org/'

ruby '3.0.0'

# Return early if this file is parsed by the Bundler plugin DSL.
# This won't let us access dependencies in common-gems.
return if is_a?(Bundler::Plugin::DSL)

gem 'rails', '~> 6.1.0'

# Load common gems
%w(
  rails
  redis
).each do |m|
  eval_gemfile File.join('common-gems', m, 'Gemfile')
end

gem 'dotenv-rails',                             '~> 2.7'
gem 'envkey',                                   '~> 1.0'
gem 'gems',                                     '~> 1.2', require: false
gem 'git',                                      '~> 1.5'
gem 'rails_bootstrap_navbar',                   '~> 3.0'
gem 'sidekiq',                                  '~> 5.0'
gem 'sitemap_generator',                        '~> 6.1', require: false
gem 'aws-sdk-s3',                               '~> 1.83', require: false

group :development do
  gem 'spring',                                 '~> 2.0'
  gem 'spring-watcher-listen',                  '~> 2.0'
end

group :development, :test do
  gem 'factory_bot_rails',                      '~> 6.1'
  gem 'rspec-rails',                            '~> 4.0.1'
end
