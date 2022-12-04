# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "active_record_extended",                   "~> 3.0"
gem "amazing_print",                            "~> 1.4",  require: false
gem "aws-sdk-s3",                               "~> 1.8"
gem "baseline",                                 github: "manuelmeurer/baseline"
gem "bootsnap",                                 "~> 1.13", require: false
gem "bootstrap",                                "~> 5.2"
gem "envkey",                                   "~> 1.0"
gem "gems",                                     "~> 1.2"
gem "git",                                      "~> 1.12"
gem "haml",                                     "~> 6.0"
gem "hiredis",                                  "~> 0.6"
gem "importmap-rails",                          "~> 1.1"
gem "kredis",                                   "~> 1.2"
gem "mini_racer",                               "~> 0.6" # Necessary for autoprefixer-rails, which is required by bootstrap.
gem "pg",                                       "~> 1.4"
gem "postmark-rails",                           "~> 0.22"
gem "pry",                                      "~> 0.14", require: false
gem "puma",                                     "~> 6.0"
gem "rack-cors",                                "~> 1.0"
gem "rails_bootstrap_navbar",                   "~> 3.0"
gem "rails",                                    "~> 7.0.3"
gem "redis-namespace",                          "~> 1.9"
gem "redis",                                    "~> 4.0"
gem "sassc-rails",                              "~> 2.1"
gem "sentry-rails",                             "~> 5.5"
gem "sentry-sidekiq",                           "~> 5.5"
gem "sidekiq-scheduler",                        "~> 4.0"
gem "sidekiq",                                  "~> 6.5"
gem "sitemap_generator",                        "~> 6.3"
gem "sprockets-rails",                          "~> 3.4"
gem "stimulus-rails",                           "~> 1.1"
gem "tries",                                    "~> 0.4"
gem "turbo-rails",                              "~> 1.1"

group :development do
  gem "annotate",                               "~> 3.0", require: false
  gem "better_errors",                          "~> 2.8"
  gem "binding_of_caller",                      "~> 1.0"
  gem "database_consistency",                   "~> 1.0", require: false
  gem "marginalia",                             "~> 1.4"
end

group :development, :test do
  gem "dotenv-rails",                           "~> 2.8", require: "dotenv/rails-now"
end
