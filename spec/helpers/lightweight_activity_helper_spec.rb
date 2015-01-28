require "spec_helper"

describe LightweightActivityHelper do
  let(:activity)     { mock_model LightweightActivity, {:id => 23}}
  let(:sequence)     { mock_model Sequence,   {:id => 1}        }
  let(:sequence_path){ "/sequences/1/activities/23" }
  let(:path_no_run)  { "/activities/23" }

  subject { helper.runnable_activity_path(activity) }

  describe "#runnable_activity_path" do
    describe "with a sequence" do
      it "should just use the activity path" do
        assign(:sequence, sequence)
        expect(subject).to eql(sequence_path)
      end
    end
    describe "without anything" do
      it "should just use the activity path" do
        expect(subject).to eql(path_no_run)
      end
    end
  end
end
