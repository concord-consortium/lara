# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) { |n| Faker::Internet.email }

  factory :user do
    email { generate(:email) }
    password 'passwrod...'
    password_confirmation 'passwrod...'
    is_admin false
  end

  factory :admin, :class => User do
    email { generate(:email) }
    password 'admin...'
    password_confirmation 'admin...'
    is_admin true
  end

  factory :author, :class => User do
    email { generate(:email) }
    password 'author..'
    password_confirmation 'author..'
    is_admin false
    is_author true
  end
end
