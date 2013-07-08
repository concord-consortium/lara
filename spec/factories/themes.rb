# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme do
    name { generate(:name) }
    css_file { generate(:name) }
  end
end
