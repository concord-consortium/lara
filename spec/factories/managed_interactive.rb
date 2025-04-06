# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence (:mi_url_fragment) { Faker::Lorem.characters(number: 20) }

  factory :managed_interactive do
    name { generate(:name) }
    url_fragment  { generate(:mi_url_fragment) }
  end
end
