require 'spec_helper'

describe Sequence do
  let (:user) { FactoryGirl.create(:user) }
  let (:sequence_opts) { {} }
  let (:sequence) {
      sequence = FactoryGirl.create(:sequence, sequence_opts)
      sequence.user = user
      sequence.save
      sequence
    }
  let (:activity1) {
     activity = FactoryGirl.create(:activity, :time_to_complete => 45)
     activity.user = user
     activity.save
     activity
    }
  let (:activity2) {
     activity = FactoryGirl.create(:activity, :time_to_complete => 40)
     activity.user = user
     activity.save
     activity
    }
  let(:thumbnail_url) { "http://i.huffpost.com/gen/1469621/thumbs/o-MARK-TWAIN-facebook.jpg" }

  it 'has valid attributes' do
    expect(sequence).to be_valid
  end

  it 'calculates a cumulative time-to-complete' do
    expect(sequence.time_to_complete).to be(0)
    sequence.lightweight_activities = [activity1, activity2]
    expect(sequence.time_to_complete).to be(activity1.time_to_complete + activity2.time_to_complete)
  end

  it 'returns the same items for #activities as #lightweight_activities' do
    expect(sequence.activities).to eq(sequence.lightweight_activities)
    sequence.lightweight_activities = [activity1, activity2]
    expect(sequence.activities).to eq(sequence.lightweight_activities)
  end

  describe '#next_activity' do

    before do
      sequence.lightweight_activities = []
      sequence.lightweight_activities = [activity1, activity2]
    end

    it 'returns the activity with the next-highest position value in the sequence' do
      expect(sequence.next_activity(sequence.activities.first)).to eq(sequence.activities.last)
    end

    it 'returns nil if there is no next activity' do
      expect(sequence.next_activity(sequence.activities.last)).to be_nil
    end
  end

  describe '#previous_activity' do

    before do
      sequence.lightweight_activities = []
      sequence.lightweight_activities = [activity1, activity2]
    end

    it 'returns the activity with the next-lowest position value in the sequence' do
      expect(sequence.previous_activity(sequence.activities.last)).to eq(sequence.activities.first)
    end

    it 'returns nil if there is no previous activity' do
      expect(sequence.previous_activity(sequence.activities.first)).to be_nil
    end
  end

  describe '#serialize_for_portal' do
    let(:user) { FactoryGirl.create(:user) }
    let(:act1) {
      activity = FactoryGirl.build(:activity_with_page)
      activity.user = user
      activity.save
      activity
    }
    let(:act2) {
      activity = FactoryGirl.build(:activity_with_page)
      activity.user = user
      activity.save
      activity
    }
    let(:sequence_with_activities) do
      seq = FactoryGirl.build(:sequence, sequence_opts)
      seq.thumbnail_url = thumbnail_url
      seq.activities << act1
      seq.activities << act2
      seq.user = user
      seq.save!
      # Reorder activities - move first one to the bottom.
      seq.lightweight_activities_sequences.find { |as| as.lightweight_activity ==act1 }.move_to_bottom
      seq.reload
      seq
    end

    let (:activity_player_sequence) {
      activity_player_sequence = FactoryGirl.create(:activity_player_sequence, sequence_opts)
      activity_player_sequence.thumbnail_url = thumbnail_url
      activity_player_sequence.user = user
      activity_player_sequence.save
      activity_player_sequence
    }

    let(:simple_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence)}"
      author_url = "#{url}/edit"
      print_url = "#{url}/print_blank"
      {
        "source_type" => "LARA",
        "type"=>"Sequence", "name"=> sequence.title, "description"=> sequence.description,
        "abstract" => sequence.abstract,
        "url"=> url,
        "create_url"=> url,
        "author_url"    => author_url,
        "print_url"     => print_url,
        "thumbnail_url" => nil, # our simple sequence doesn't have one
        "author_email" => sequence.user.email,
        "activities"=>[],
        "append_auth_token" => false,
        "tool_id" => ""
      }
    end

    let(:complex_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence_with_activities)}"
      author_url = "#{url}/edit"
      print_url = "#{url}/print_blank"
      {
        "source_type" => "LARA",
        "type"=>"Sequence", "name"=> sequence_with_activities.title, "description"=> sequence_with_activities.description,
        "abstract" => sequence_with_activities.abstract,
        "url"=> url,
        "create_url"=> url,
        "author_url"    => author_url,
        "print_url"     => print_url,
        "thumbnail_url" => thumbnail_url,
        "author_email" => sequence_with_activities.user.email,
        "activities"=> [
          # Note that we reordered activities!
          act2.serialize_for_portal("http://test.host"),
          act1.serialize_for_portal("http://test.host")
        ],
        "append_auth_token" => false,
        "tool_id" => ""
      }
    end

    let(:ap_simple_portal_hash) do
      url = "http://test.host#{Rails.application.routes.url_helpers.sequence_path(activity_player_sequence)}"
      author_url = "#{url}/edit"
      print_url = "#{url}/print_blank"
      ap_url = "#{ENV["ACTIVITY_PLAYER_URL"]}?sequence=http://test.host/api/v1/sequences/#{activity_player_sequence.id}.json"
      {
        "source_type" => "Activity Player",
        "type"=>"Sequence", "name"=> activity_player_sequence.title, "description"=> activity_player_sequence.description,
        "abstract" => activity_player_sequence.abstract,
        "url"=> ap_url,
        "create_url"=> ap_url,
        "author_url"    => author_url,
        "print_url"     => print_url,
        "thumbnail_url" => activity_player_sequence.thumbnail_url,
        "author_email" => activity_player_sequence.user.email,
        "activities"=>[],
        "append_auth_token" => true,
        "tool_id" => ENV["ACTIVITY_PLAYER_URL"]
      }
    end

    it 'returns a hash for a simple sequence that can be consumed by the Portal' do
      expect(sequence.serialize_for_portal('http://test.host')).to eq(simple_portal_hash)
    end

    it 'returns a hash for a sequence with activities that can be consumed by the Portal' do
      expect(sequence_with_activities.serialize_for_portal("http://test.host")).to eq(complex_portal_hash)
    end

    it 'returns a simple hash for an Activity Player sequence that can be consumed by the Portal' do
      expect(activity_player_sequence.serialize_for_portal('http://test.host')).to eq(ap_simple_portal_hash)
    end

  end

  describe '#serialize_for_report_service' do
    let(:act1) {
      FactoryGirl.build(:activity_with_page)
    }
    let(:act2) {
      FactoryGirl.build(:activity_with_page)
    }
    let(:sequence_with_activities) do
      seq = FactoryGirl.build(:sequence)
      seq.activities << act1
      seq.activities << act2
      seq.save!
      # Reorder activities - move first one to the bottom.
      seq.lightweight_activities_sequences.find { |as| as.lightweight_activity ==act1 }.move_to_bottom
      seq.reload
      seq
    end

    let(:simple_report_service_hash) do
      {
        id: "sequence_#{sequence.id}",
        type: "sequence",
        name: sequence.title,
        url: "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence)}",
        migration_status: "unknown",
        children: []
      }
    end

    let(:complex_report_service_hash) do
      {
        id: "sequence_#{sequence_with_activities.id}",
        type: "sequence",
        name: sequence_with_activities.title,
        url: "http://test.host#{Rails.application.routes.url_helpers.sequence_path(sequence_with_activities)}",
        migration_status: "not_migrated",
        children: [
          # Note that we reordered activities!
          act2.serialize_for_report_service("http://test.host"),
          act1.serialize_for_report_service("http://test.host")
        ]
      }
    end

    it 'returns a hash for a simple sequence that can be consumed by the report service' do
      expect(sequence.serialize_for_report_service('http://test.host')).to eq(simple_report_service_hash)
    end

    it 'returns a hash for a simple sequence with a preview_url when sequence has an activity player runtime that can be consumed by the report service' do
      sequence.runtime = "Activity Player"
      ap_hash = simple_report_service_hash
      ap_hash[:preview_url] = "https://activity-player.concord.org/branch/master?sequence=http%3A%2F%2Ftest.host%2Fapi%2Fv1%2Fsequences%2F#{sequence.id}.json&preview"
      expect(sequence.serialize_for_report_service('http://test.host')).to eq(simple_report_service_hash)
    end

    it 'returns a hash for a sequence with activities that can be consumed by the report service' do
      expect(sequence_with_activities.serialize_for_report_service("http://test.host")).to eq(complex_report_service_hash)
    end
  end

  describe '#to_hash' do
    let(:sequence_opts) { {} }
    it 'returns a hash with relevant values for sequence duplication' do
      expected = {
        title: sequence.title,
        description: sequence.description,
        publication_status: sequence.publication_status,
        abstract: sequence.abstract,
        theme_id: sequence.theme_id,
        logo: sequence.logo,
        project: sequence.project,
        display_title: sequence.display_title,
        thumbnail_url: sequence.thumbnail_url,
        runtime: "LARA"
      }
      expect(sequence.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    let(:sequence_opts) { {} }
    it 'returns json of a sequence' do
      sequence_json = JSON.parse(sequence.export)
      expect(sequence_json['activities'].length).to eq(sequence.activities.count)
    end

    it 'does not include the fixed width layout option' do
      sequence_json = JSON.parse(sequence.export)
      expect(sequence_json).not_to include('fixed_width_layout')
    end

    describe 'for activity player sequences' do
      let (:activity_player_sequence) {
        activity_player_sequence = FactoryGirl.create(:activity_player_sequence, sequence_opts)
        activity_player_sequence.thumbnail_url = thumbnail_url
        activity_player_sequence.user = user
        activity_player_sequence.save
        activity_player_sequence
      }

      it 'does include the fixed width layout option' do
        sequence_json = JSON.parse(activity_player_sequence.export)
        expect(sequence_json).to include('fixed_width_layout')
      end
    end
  end

  describe '#import' do
    let(:logo)          { "https://concord.org/logo.jpg" }
    let(:thumbnail_url) { "https://concord.org/sunflower.jpg" }
    let(:title)         { "title" }
    let(:sequence_opts) { {logo: logo, thumbnail_url: thumbnail_url, title: title} }
    let(:owner)         { FactoryGirl.create(:user) }

    it 'returns json of a sequence' do
      data = JSON.parse(sequence.export, :symbolize_names => true)
      imported = Sequence.import(data, owner)
      expect(imported.thumbnail_url).to eq(thumbnail_url)
      expect(imported.logo).to eq(logo)
    end
  end
  describe '#duplicate' do
    let(:sequence_opts) { {} }
    let(:owner)         { FactoryGirl.create(:user) }
    let(:act1) {
      activity = FactoryGirl.build(:activity_with_page)
      activity.user = owner
      activity.save
      activity
    }
    let(:act2) {
      activity = FactoryGirl.build(:activity_with_page)
      activity.user = owner
      activity.save
      activity
    }
    let(:act3) {
      activity = FactoryGirl.build(:activity_with_page)
      activity.user = owner
      activity.save
      activity
    }
    let(:sequence_with_activities) do
      seq = FactoryGirl.build(:sequence)
      seq.thumbnail_url = thumbnail_url
      seq.activities << act1
      seq.activities << act2
      seq.activities << act3
      seq.user = owner
      seq.save!
      seq
    end

    it 'creates a new Sequence with attributes from the original' do
      dup = sequence.duplicate(owner)
      dup.reload # make sure that all changes are saved to db.
      expect(dup).to be_a(Sequence)
      expect(dup.user).to eq(owner)
      expect(dup.title).to eq("Copy of #{sequence.title}")
      expect(dup.description).to eq(sequence.description)
      expect(dup.theme_id).to eq(sequence.theme_id)
      expect(dup.project_id).to eq(sequence.project_id)
      expect(dup.logo).to eq(sequence.logo)
      expect(dup.display_title).to eq(sequence.display_title)
      expect(dup.thumbnail_url).to eq(sequence.thumbnail_url)
      expect(dup.activities.length).to eq(sequence.activities.length)
    end

    it 'performs deep copy of all activities included in a given sequence' do
      dup = sequence_with_activities.duplicate(owner)
      dup.reload # make sure that all changes are saved to db.
      expect(dup.activities.length).to eq(sequence_with_activities.activities.length)
      dup.activities.zip(sequence_with_activities.activities).each do |a, b|
        expect(a).not_to eq(b) # deep copy!
        expect(a.user).to eq(owner)
        expect(a.name).to eq(b.name) # we don't want "Copy of" prefix here
        expect(a.related).to eq(b.related)
        expect(a.description).to eq(b.description)
        expect(a.time_to_complete).to eq(b.time_to_complete)
      end
    end

    it 'keeps order of activities from the original' do
      dup = sequence_with_activities.duplicate(owner)
      dup.reload # make sure that all changes are saved to db.
      dup.lightweight_activities_sequences.zip(sequence_with_activities.lightweight_activities_sequences) do |a, b|
        expect(a.position).to eq(b.position)
        expect(a.lightweight_activity.name).to eq(b.lightweight_activity.name)
      end
    end

    it 'keeps order of activities from the original even when it was modified' do
      sequence_with_activities.lightweight_activities_sequences[0].update_attributes!(position: 2)
      sequence_with_activities.lightweight_activities_sequences[1].update_attributes!(position: 1)
      sequence_with_activities.lightweight_activities_sequences[2].update_attributes!(position: 3)
      dup = sequence_with_activities.duplicate(owner)
      dup.reload # make sure that all changes are saved to db.
      sequence_with_activities.reload # make sure that order is updated so test below makes sense.
      dup.lightweight_activities_sequences.zip(sequence_with_activities.lightweight_activities_sequences) do |a, b|
        expect(a.position).to eq(b.position)
        expect(a.lightweight_activity.name).to eq(b.lightweight_activity.name)
      end
    end
  end

  describe "#activity_player_sequence_url" do
    let(:base_url) { "http://test.host" }
    describe "with an activity" do
      it "should return a URI containing the required param" do
        activity_player_sequence_url = sequence.activity_player_sequence_url(base_url, preview: true)
        uri = URI.parse(activity_player_sequence_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["sequence"]).to eq("http://test.host/api/v1/sequences/#{sequence.id}.json")
        expect(query).to have_key("preview")
        expect(query["preview"]).to be_nil
        expect(query).to_not have_key("mode")
      end
    end
    describe "with an activity and teacher mode enabled" do
      it "should return a URI containing the required params" do
        activity_player_sequence_url = sequence.activity_player_sequence_url(base_url, preview: true, mode:"teacher-edition")
        uri = URI.parse(activity_player_sequence_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["sequence"]).to eq("http://test.host/api/v1/sequences/#{sequence.id}.json")
        expect(query).to have_key("preview")
        expect(query["preview"]).to be_nil
        expect(query["mode"]).to eq("teacher-edition")
      end
    end
  end

end
