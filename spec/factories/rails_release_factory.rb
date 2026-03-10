FactoryBot.define do
  factory :rails_release do
    version { "7.1" }
    minimum_ruby_version { "3.0.0" }
    minimum_bundler_version { "2.4.0" }
  end
end