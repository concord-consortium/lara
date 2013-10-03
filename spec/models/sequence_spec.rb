require 'spec_helper'

describe Sequence do
  let (:sequence) { FactoryGirl.create(:sequence) }
  let (:activity1) { FactoryGirl.create(:activity, :time_to_complete => 45) }
  let (:activity2) { FactoryGirl.create(:activity, :time_to_complete => 40) }

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

  describe '#next_activity' do

    before(:all) do
      sequence.lightweight_activities = []
      sequence.lightweight_activities = [activity1, activity2]
    end

    it 'returns the activity with the next-highest position value in the sequence' do
      sequence.next_activity(sequence.activities.first).should == sequence.activities.last
    end

    it 'returns nil if there is no next activity' do
      sequence.next_activity(sequence.activities.last).should be_nil
    end
  end

  describe '#previous_activity' do

    before(:all) do
      sequence.lightweight_activities = []
      sequence.lightweight_activities = [activity1, activity2]
    end

    it 'returns the activity with the next-lowest position value in the sequence' do
      sequence.previous_activity(sequence.activities.last).should == sequence.activities.first
    end

    it 'returns nil if there is no previous activity' do
      sequence.previous_activity(sequence.activities.first).should be_nil
    end
  end

  describe '#serialize_for_portal' do
    let(:act1) { FactoryGirl.build(:activity_with_page) }
    let(:sequence_with_activities) do
      seq = FactoryGirl.build(:sequence)
      seq.activities << act1
      seq.save!
      seq
    end

    let(:simple_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence)}"
      {"type"=>"Sequence", "name"=> sequence.title, "description"=> sequence.description,
        "url"=> url,
        "create_url"=> url,
        "activities"=>[]
      }
    end

    let(:complex_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence_with_activities)}"
      {"type"=>"Sequence", "name"=> sequence.title, "description"=> sequence.description,
        "url"=> url,
        "create_url"=> url,
        "activities"=>[act1.serialize_for_portal("http://test.host")]
      }
    end

    it 'returns a hash for a simple sequence that can be consumed by the Portal' do
      sequence.serialize_for_portal('http://test.host').should == simple_portal_hash
    end

    it 'returns a hash for a sequence with activities that can be consumed by the Portal' do
      sequence_with_activities.serialize_for_portal("http://test.host").should == complex_portal_hash
    end

  end

end
