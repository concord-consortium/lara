# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence (:li_url) { Faker::Internet.url() }

  factory :library_interactive do
    native_width { 100 }
    native_height { 200 }
    name { generate(:name) }
    base_url  { generate(:li_url) }
    image_url  { generate(:li_url) }
    thumbnail_url  { generate(:li_url) }
    created_at { Time.now.change(usec: 0) }
    updated_at { Time.now.change(usec: 0) }
  end
end
