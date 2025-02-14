FactoryBot.define do
  factory :rubric, class: Rubric do
    name { generate(:name) }
  end
end