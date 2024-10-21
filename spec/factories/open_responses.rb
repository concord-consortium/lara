FactoryGirl.define do
  sequence(:default_text) { Faker::Lorem.sentence(word_count: 8) }

  factory :open_response, :class=> Embeddable::OpenResponse do |f|

    factory :hidden_open_response do
      is_hidden true
    end
  end
end

