source "https://rubygems.org"

ruby file: ".ruby-version"

# gem "activerecord-enhancedsqlite3-adapter",     "~> 0.5"
gem "amazing_print",                            "~> 1.5"
gem "aws-sdk-s3",                               "~> 1.8",  require: false
gem "baseline",                                 github: "fastruby/baseline"
gem "bootsnap",                                 "~> 1.17", require: false
gem "bootstrap",                                "~> 5.3.3"
gem "dartsass-rails",                           "~> 0.5"
gem "dotenv",                                   "~> 3.1.2"
gem "faraday"
gem "faraday_middleware"
gem "faraday-multipart"
gem "faraday-retry"
gem "fog-aws"
gem "gems",                                     github: "rubygems/gems" # TODO: use released version when > 1.2.0 is released
gem "git",                                      "~> 2.1"
gem "haml",                                     "~> 6.0"
gem "importmap-rails",                          "~> 2.0"
gem "kredis",                                   "~> 1.2"
gem "net-pop",                                  github: "ruby/net-pop"
gem "octokit",                                  "~> 9.1"
gem "octopoller",                               "~> 0.3"
gem "propshaft",                                "~> 0.8"
gem "pry-rails",                                "~> 0.3"
gem "puma",                                     "~> 6.4"
gem "rails_bootstrap_navbar",                   "~> 3.0"
gem "rails",                                    "~> 8.0.0"
gem "rails-i18n",                               "~> 8.0.0"
gem "redis-namespace",                          "~> 1.11"
gem "redis",                                    "~> 5.0"
gem "sentry-rails",                             "~> 5.5"
gem "sentry-sidekiq",                           "~> 5.5"
gem "sidekiq-scheduler",                        "~> 5.0"
gem "sidekiq",                                  "~> 7.2"
gem "sitemap_generator",                        "~> 6.3"
gem "stimulus-rails",                           "~> 1.3"
gem "turbo-rails",                              "~> 2.0"

group :development do
  gem "annotaterb",                             "~> 4.4", require: false
  gem "better_errors",                          "~> 2.8"
  gem "binding_of_caller",                      "~> 1.0"
end

# Run against this stable release
group :development, :test do
  gem "byebug",                                  "~> 11.1"
  gem "codecov", require: false
  gem "database_cleaner-active_record"
  gem "factory_bot_rails",                       "~> 6.2"
  gem "rspec-rails", "~> 6.1.0"
  gem "rails-controller-testing"
  gem "simplecov", "~> 0.22", require: false
  gem "simplecov-console", require: false
  gem "vcr"
  gem "webmock"
end

gem "pg"
