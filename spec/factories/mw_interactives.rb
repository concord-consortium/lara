# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence (:url) { Faker::Internet.url() }

  factory :mw_interactive do
    name { generate(:name) }
    url  { generate(:url) }

    factory :hidden_mw_interactive do
      is_hidden { true }
    end
  end
end
