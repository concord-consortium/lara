# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:project_key)  { |n| "text-key-#{n}" }

  factory :project do
    about "MyText"
    footer "MyText"
    help "MyText"
    logo_ap "MyString"
    logo_lara "MyString"
    project_key { generate(:project_key) }
    title "MyString"
    url "MyString"
  end
end
