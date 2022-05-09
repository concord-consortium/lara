# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :setting do
    key { generate(:name) }
    value { generate(:name) }
  end
end
