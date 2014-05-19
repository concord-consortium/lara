require "spec_helper"

describe LightweightActivityHelper do
  let(:run_key)      {"3919e6ab-42c2-4f16-afe2-c1a42554228b"}
  let(:activity)     { mock_model LightweightActivity, {:id => 23}}
  let(:run)          { mock "run", {:key => run_key }           }
  let(:sequence_run) { mock "s_run", {:run_for_activity => run} }
  let(:sequence)     { mock_model Sequence,   {:id => 1}        }
  let(:path_with_run){ "/activities/23/3919e6ab-42c2-4f16-afe2-c1a42554228b"}
  let(:sequence_path){ "/sequences/1/activities/23" }
  let(:path_no_run)  { "/activities/23" }

  subject { helper.runnable_activity_path(activity) }

  describe "#runnable_activity_path" do
    describe "with a sequence run" do
      it "should use the sequence run activity key" do
        assign(:sequence_run, sequence_run)
        subject.should eql(path_with_run)
      end
    end
    describe "with a activity run" do
      it "should use the run key" do
        assign(:run, run)
        subject.should eql(path_with_run)
      end
    end
    describe "with a sequence" do
      it "should just use the activity path" do
        assign(:sequence, sequence)
        puts subject
        subject.should eql(sequence_path)
      end
    end
    describe "without anything" do
      it "should just use the activity path" do
        subject.should eql(path_no_run)
      end
    end
  end
end
