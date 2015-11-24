FactoryGirl.define do
  factory :rubygem do
    name Faker::Lorem.word
    status_rails4 'ready'
    status_rails5 'ready'
    notes_rails4 Faker::Lorem.paragraph
    notes_rails5 Faker::Lorem.paragraph

    trait :is_ready do
      status_rails4 'ready'
      status_rails5 'ready'
    end
    trait :not_ready do
      status_rails4 'not ready'
      status_rails5 'not ready'
    end
    trait :unknown do
      status_rails4 'unknown'
      status_rails5 'unknown'
    end

  end
end
