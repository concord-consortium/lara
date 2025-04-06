require "spec_helper"

describe SequenceHelper do
  let(:activity)     { FactoryBot.create(:activity, id: 23, name: "Test Activity") }
  let(:sequence)     { FactoryBot.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}
  let(:activity_player_activity)  { FactoryBot.create(:activity, id: 24, name: "AP Test Activity") }
  let(:activity_player_sequence)  { FactoryBot.create(:sequence, id: 2, title: "AP Test Sequence",
    lightweight_activities: [activity_player_activity])}

  describe "#sequence_preview_options" do
    describe "with an activity" do
      it "should return a list of preview options" do
        @sequence = sequence
        preview_options = helper.sequence_preview_options(activity)
        expect(preview_options["Select a runtime option..."]).to eq("")
      end
    end
  end

  describe "#sequence_runtime_url" do
    context "with an activity player runtime" do
      it "returns an activity player url" do
        url = "https://activity-player.concord.org/branch/master" +
          "?sequence=http%3A%2F%2Ftest.host%2Fapi%2Fv1%2Fsequences%2F#{activity_player_sequence.id}.json&preview"
        expect(helper.sequence_runtime_url(activity_player_sequence)).to eq(url)
      end
    end
  end

  describe "#activity_sequence_preview_url" do
    before(:each) do
      @sequence = sequence
    end
    describe "with an Activity Player runtime sequence" do
      before(:each) do
        @sequence.lightweight_activities = [activity_player_activity]
      end
      it "should return an AP URL" do
        url = "https://activity-player.concord.org/branch/master" +
        "?sequence=http%3A%2F%2Ftest.host%2Fapi%2Fv1%2Fsequences%2F#{@sequence.id}.json&preview&sequenceActivity=#{activity_player_activity.id}"
        expect(helper.activity_sequence_preview_url(activity_player_activity)).to eq(url)
      end
    end
  end

end
