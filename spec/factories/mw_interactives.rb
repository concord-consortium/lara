# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence (:url) { Faker::Internet.url() }

  factory :mw_interactive do
    name { generate(:name) }
    url  { generate(:url) }
  end
end
