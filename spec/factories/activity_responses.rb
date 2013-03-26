# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:session_key) { Faker::Lorem.characters(16) }
  
  factory :activity_response do
    key { generate(:session_key) }
    responses { generate(:related) }
    user_id 1
    activity_id 1
  end
end
