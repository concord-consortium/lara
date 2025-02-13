# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence(:prompt) { Faker::Lorem.sentence(word_count: 8) }
  sequence(:choice) { Faker::Lorem.sentence(word_count: 2) }

  factory :mc_embeddable, class: Embeddable::MultipleChoice do
    name    { generate(:name) }
    prompt  { generate(:prompt) }
    factory :mc_with_choices, class: Embeddable::MultipleChoice do
      after(:create) do |mc_embeddable, evaluator|
        mc_embeddable.create_default_choices
      end
    end
  end

  factory :mcc_embeddable, class: Embeddable::MultipleChoiceChoice do
    choice  { generate(:choice) }
    prompt  { generate(:prompt) }
  end

end
