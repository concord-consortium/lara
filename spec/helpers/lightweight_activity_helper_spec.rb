require "spec_helper"

describe LightweightActivityHelper do
  let(:activity)     { FactoryGirl.create(:activity, :id => 23) }
  let(:sequence)     { FactoryGirl.create(:sequence, :id => 1, :lightweight_activities => [activity])}
  let(:user)         { FactoryGirl.create(:user) }
  let(:sequence_run) { FactoryGirl.create(:sequence_run, :sequence_id     => sequence.id, :user_id         => user.id) }
  let(:run)          { FactoryGirl.create(:run, {key: "012345678901234567890123456789123456", sequence_run: sequence_run, activity: activity, user: user})}
  let(:sequence_path_with_run){ "/sequences/1/activities/23/012345678901234567890123456789123456" }
  let(:sequence_path){ "/sequences/1/activities/23" }
  let(:path_no_run)  { "/activities/23" }

  subject { helper.runnable_activity_path(activity) }

  describe "#runnable_activity_path" do
    describe "with a sequence and sequence run" do
      it "should use the sequence with run path" do
        assign(:run, run)
        assign(:sequence, sequence)
        assign(:sequence_run, sequence_run)
        expect(subject).to eql(sequence_path_with_run)
      end
    end
    describe "with a sequence" do
      it "should use the sequence path" do
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
