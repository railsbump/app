FactoryBot.define do
  factory :gem_check do
    lockfile_check
    gem_name { "some_gem" }
    locked_version { "1.0.0" }
    source { GemCheck::RUBYGEMS_SOURCE }
    status { "pending" }
  end
end
