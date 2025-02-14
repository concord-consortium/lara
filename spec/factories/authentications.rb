# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :authentication do
    user_id { 1 }
    provider { "MyString" }
    uid { "MyString" }
  end
end
