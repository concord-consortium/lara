FactoryGirl.define do
  factory :collaboration_run, class: CollaborationRun do |f|
    user_id 1
    collaborators_data_url "http://some.portal.concord.org/collaborations/123"
  end
end
