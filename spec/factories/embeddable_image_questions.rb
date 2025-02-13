# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :image_question, class: 'Embeddable::ImageQuestion' do
    name { "First Image Question" }
    prompt { "Why do birds squeek? Show your work." }
  end
end
