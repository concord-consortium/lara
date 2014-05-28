require 'spec_helper'

describe Sequence do
  let (:sequence) { FactoryGirl.create(:sequence) }
  let (:activity1) { FactoryGirl.create(:activity, :time_to_complete => 45) }
  let (:activity2) { FactoryGirl.create(:activity, :time_to_complete => 40) }
  let(:thumbnail_url) { "http://i.huffpost.com/gen/1469621/thumbs/o-MARK-TWAIN-facebook.jpg" }

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
      seq.thumbnail_url = thumbnail_url
      seq.activities << act1
      seq.save!
      seq
    end

    let(:simple_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence)}"
      {"type"=>"Sequence", "name"=> sequence.title, "description"=> sequence.description,
        "url"=> url,
        "create_url"=> url,
        "thumbnail_url" => nil, # our simple sequence doesn't have one
        "activities"=>[]
      }
    end

    let(:complex_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence_with_activities)}"
      {"type"=>"Sequence", "name"=> sequence.title, "description"=> sequence.description,
        "url"=> url,
        "create_url"=> url,
        "thumbnail_url" => thumbnail_url,
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

  describe '#to_hash' do
    it 'returns a hash with relevant values for sequence duplication' do
      expected = { title: sequence.title, description: sequence.description, theme_id: sequence.theme_id, project_id: sequence.project_id,
                   logo: sequence.logo, display_title: sequence.display_title, thumbnail_url: sequence.thumbnail_url }
      sequence.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    let(:sequence_with_activities) do
      seq = FactoryGirl.build(:sequence)
      seq.thumbnail_url = thumbnail_url
      seq.activities << FactoryGirl.build(:activity_with_page)
      seq.activities << FactoryGirl.build(:activity_with_page)
      seq.activities << FactoryGirl.build(:activity_with_page)
      seq.save!
      seq
    end

    it 'creates a new Sequence with attributes from the original' do
      dup = sequence.duplicate
      dup.should be_a(Sequence)
      dup.title.should == "Copy of #{sequence.title}"
      dup.description.should == sequence.description
      dup.theme_id.should == sequence.theme_id
      dup.project_id.should == sequence.project_id
      dup.logo.should == sequence.logo
      dup.display_title.should == sequence.display_title
      dup.thumbnail_url.should == sequence.thumbnail_url
      dup.activities.length.should == sequence.activities.length
    end

    it 'performs deep copy of all activities included in a given sequence' do
      dup = sequence_with_activities.duplicate
      dup.activities.length.should == sequence_with_activities.activities.length
      dup.activities.zip(sequence_with_activities.activities).each do |a, b|
        a.should_not == b # deep copy!
        a.name.should == b.name # we don't want "Copy of" prefix here
        a.related.should == b.related
        a.description.should == b.description
        a.time_to_complete.should == b.time_to_complete
      end
    end

    it 'keeps order of activities from the original' do
      dup.lightweight_activities_sequences.zip(sequence_with_activities.lightweight_activities_sequences) do |a, b|
        a.position.should == b.position
      end
    end
  end

end
