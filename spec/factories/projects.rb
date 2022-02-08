# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:project_key)  { |n| "text-key-#{n}" }

  factory :project do
    about "MyText"
    footer "MyText"
    logo_ap "MyString"
    logo_lara "MyString"
    project_key { generate(:project_key) }
    title "MyString"
    url "MyString"
    copyright "MyString"
    copyright_image_url "MyString"
    collaborators "MyString"
    funders_image_url "MyString"
    collaborators_image_url "MyString"
    contact_email "MyString"
  end
end
