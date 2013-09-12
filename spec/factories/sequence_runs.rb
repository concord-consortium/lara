# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sequence_run do
    user_id 1
    remote_id "01002"
    remote_endpoint "http://portal.com/blarg/learnerpost/34233"
  end
end
