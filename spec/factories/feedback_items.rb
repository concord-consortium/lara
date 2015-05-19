FactoryGirl.define do
  factory :feedback_item, class: 'Embeddable::FeedbackItem' do
  end
end

FactoryGirl.define do
  factory :c_rater_feedback_item, class: 'CRater::FeedbackItem' do
  end
end
