# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:project_key)  { |n| "text-key-#{n}" }

  factory :project do
    about "MyText"
    copyright "MyString"
    copyright_image_url "MyString"
    collaborators "MyString"
    collaborators_image_url "MyString"
    contact_email "MyString"
    footer "MyText"
    funders_image_url "MyString"
    logo_ap "cc-logo.png"
    logo_lara "cc-logo.png"
    project_key { generate(:project_key) }
    title "MyString"
    url "MyString"
    created_at { Time.now.change(usec: 0) }
    updated_at { Time.now.change(usec: 0) }
  end
end
