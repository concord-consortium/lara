require "spec_helper"

describe SequenceHelper do
  let(:activity)     { FactoryGirl.create(:activity, id: 23, name: "Test Activity") }
  let(:sequence)     { FactoryGirl.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}
  let(:activity_player_sequence) { FactoryGirl.create(:sequence, id: 1, title: "Test Sequence",
    runtime: "Activity Player", lightweight_activities: [activity])}

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
    context "with a LARA runtime" do
      it "returns a LARA url" do
        expect(helper.sequence_runtime_url(sequence)).to eq("/sequences/#{sequence.id}")
      end
    end
  end

end
