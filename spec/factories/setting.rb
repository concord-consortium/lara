# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :setting do
    key { generate(:name) }
    value { generate(:name) }
  end
end
