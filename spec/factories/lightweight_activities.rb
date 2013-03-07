# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:name) { |n| Faker::Lorem.sentence(2)[0..49] }
  sequence(:related) { |n| Faker::Lorem.sentences(4).join(" ") }
  sequence(:description) { |n| Faker::Lorem.sentences(4).join(" ") }

  factory :activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'private'
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :public_activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
  end
end
