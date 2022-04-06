FactoryGirl.define do
  factory :glossary, :class => Glossary do
    name { generate(:name) }
    json "{}"
  end
end