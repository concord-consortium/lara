FactoryGirl.define do

  factory :run, class: Run do |f|
    # responses { generate(:related) }
    user_id 1
    activity_id 1
  end

end

