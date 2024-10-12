FactoryBot.define do
  factory :lockfile do
    slug { ActiveSupport::Digest.hexdigest("rails#rspec") }
    content { File.read("spec/fixtures/Gemfile.lock") }
  end
end