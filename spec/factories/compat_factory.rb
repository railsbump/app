FactoryBot.define do
  factory :compat do
    rails_release { RailsRelease.last || FactoryBot.create(:rails_release) }

    dependencies { {"mail"=>"~> 2.2", "rspec"=>"~> 2.0"} }
  end
end