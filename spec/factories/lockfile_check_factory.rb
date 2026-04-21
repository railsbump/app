FactoryBot.define do
  factory :lockfile_check do
    lockfile
    rails_release
    ruby_version { "3.3.0" }
    rubygems_version { "3.5.0" }
    bundler_version { "2.5.0" }
  end
end
