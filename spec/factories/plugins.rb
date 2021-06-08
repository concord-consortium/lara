# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:word)         { |n| Faker::Lorem.word     }
  sequence(:sentence)     { |n| Faker::Lorem.sentence }
  sequence(:author_data)  { |n| Faker::Lorem.sentence }

  factory :approved_script do
    json_url { generate(:url) }
    name { generate(:word) }
    label { generate(:word) }
    url { generate(:url) }
    description { generate(:sentence) }
  end

  factory :plugin do
    description { generate(:sentence) }
    author_data { generate(:author_data) }
    approved_script { create(:approved_script) }
    shared_learner_state_key { generate(:word) }
  end

end
