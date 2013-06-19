require 'spec_helper'

describe Sequence do
  let (:sequence) { FactoryGirl.create(:sequence) }
  let (:activity1) { stub_model(LightweightActivity, :id => 10, :time_to_complete => 45) }
  let (:activity2) { stub_model(LightweightActivity, :id => 20, :time_to_complete => 40) }

  it 'has valid attributes' do
    sequence.should be_valid
  end

  it 'calculates a cumulative time-to-complete' do
    sequence.time_to_complete.should be(0)
    sequence.lightweight_activities = [activity1, activity2]
    sequence.time_to_complete.should be(activity1.time_to_complete + activity2.time_to_complete)
  end

  it 'returns the same items for #activities as #lightweight_activities' do
    sequence.activities.should == sequence.lightweight_activities
    sequence.lightweight_activities = [activity1, activity2]
    sequence.activities.should == sequence.lightweight_activities
  end
end
