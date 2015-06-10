# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :or_embeddable, :class => Embeddable::OpenResponse do
    name         { generate(:name) }
    prompt       { generate(:prompt) }
    default_text { generate(:default_text) }
  end
end
