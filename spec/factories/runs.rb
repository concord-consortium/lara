FactoryGirl.define do
  sequence(:session_key) { Faker::Lorem.characters(16) }

  factory :run, :class=> Run do |f|
    key { generate(:session_key) }
    # responses { generate(:related) }
    user_id 1
    activity_id 1
  end

end

