require "spec_helper"

describe SequenceHelper do
  let(:activity)     { FactoryGirl.create(:activity, id: 23, name: "Test Activity") }
  let(:sequence)     { FactoryGirl.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}

  describe "#sequence_preview_options" do
    describe "with an activity" do
      it "should return a list of preview options" do
        @sequence = sequence
        preview_options = sequence_preview_options(activity)
        expect(preview_options["Select a runtime option..."]).to eq("")
      end
    end
  end

  describe "#activity_player_sequence_url" do
    describe "with an activity" do 
      it "should return a URI containing the required param" do
        activity_player_sequence_url = activity_player_sequence_url(sequence)
        sequence_api_url = api_v1_sequence_url(sequence.id)
        uri = URI.parse(activity_player_sequence_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["sequence"]).to eq("#{sequence_api_url}.json")
        expect(query["mode"]).to eq("")
      end
    end
    describe "with an activity and teacher mode enabled" do 
      it "should return a URI containing the required params" do
        activity_player_sequence_url = activity_player_sequence_url(sequence, "teacher-edition")
        sequence_api_url = api_v1_sequence_url(sequence.id)
        uri = URI.parse(activity_player_sequence_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["sequence"]).to eq("#{sequence_api_url}.json")
        expect(query["mode"]).to eq("teacher-edition")
      end
    end
  end
end