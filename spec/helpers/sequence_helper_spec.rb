require "spec_helper"

describe SequenceHelper do
  let(:activity)     { FactoryGirl.create(:activity, id: 23, name: "Test Activity") }
  let(:sequence)     { FactoryGirl.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}

  describe "#sequence_preview_options" do
    describe "with an activity" do
      it "should return a list of preview options" do
        @sequence = sequence
        preview_options = helper.sequence_preview_options(activity)
        expect(preview_options["Select a runtime option..."]).to eq("")
      end
    end
  end
end
