FactoryGirl.define do
  
  factory :score_mapping, class: CRater::ScoreMapping do
    description { generate(:description) }
  end
  
end