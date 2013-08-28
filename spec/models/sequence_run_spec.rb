require 'spec_helper'

# syntax-sugar for forcing a let expression to evaluate
def make(thing) end

describe SequenceRun do
  let(:user)            { FactoryGirl.create(:user)            }
  let(:sequence)        { FactoryGirl.create(:sequence)        }
  let(:remote_endpoint) { "http://someplace.com/return_data/4" }
  let(:remote_id)       { "23" }

  let(:portal) do
    mock("portal",
      :remote_endpoint => remote_endpoint,
      :remote_id       => remote_id)
  end

  let(:existing_seq_run) do
    SequenceRun.create!(
      :sequence_id     => sequence.id,
      :user_id         => user.id,
      :remote_endpoint => remote_endpoint,
      :remote_id       => remote_id)
  end


  describe "class methods" do
    subject { SequenceRun }

    describe "lookup_or_create" do

      before(:each) { make existing_seq_run }

      describe "when the user has already run the sequence from the same portal" do
        it "should return the existing run" do
          subject.lookup_or_create(sequence, user, portal).should == existing_seq_run
        end
      end

      describe "when the sequence isn't the same as the existing" do
        let(:other_sequence) { FactoryGirl.create(:sequence)  }
        it "should make a new run" do
          subject.lookup_or_create(other_sequence, user, portal).should_not == existing_seq_run
        end
      end

      describe "when the user isn't the same as the existing" do
        let(:other_user) { FactoryGirl.create(:user) }
        it "should make a new run" do
          subject.lookup_or_create(sequence, other_user, portal).should_not == existing_seq_run
        end
      end

      describe "when the portal isn't the same as the existing" do
        let(:other_portal) { mock("portal", :remote_id => "something_else", :remote_endpoint => remote_endpoint) }
        it "should make a new run" do
          subject.lookup_or_create(sequence, user, other_portal).should_not == existing_seq_run
        end
      end

    end
  end

  describe "run_for_activity" do
    subject            { existing_seq_run }

    let(:activity)     { FactoryGirl.create(:activity) }
    let(:sequence)     { FactoryGirl.create(:sequence, :lightweight_activities => [activity])}
    let(:activity_run) { FactoryGirl.create(:run,
        :user => user,
        :activity => activity,
        # TODO:  The current implementation looks up the sequence runs
        # this way.  We may want to look them up using other means.
        :sequence_run => existing_seq_run)
      }

    describe "when there is no existing run for an activity for that sequence_run" do
      it "should return nil" do
        subject.run_for_activity(activity).should be_nil
      end
    end

    describe "when there is already a run for an activity for that sequence_run" do

      it "should return the existing run" do
        make activity_run
        subject.run_for_activity(activity).should == activity_run
      end
    end
  end

  describe "make_or_update_runs" do
    subject          { existing_seq_run }

    let(:activities) { Array(1..4).map { |a| FactoryGirl.create(:activity)} }
    let(:sequence)   { FactoryGirl.create(:sequence, :lightweight_activities => activities) }


    describe "when none of the activities have been previously run" do
      before(:each) do
        activities.each { |act| act.runs.should be_empty } # precondition
        subject.make_or_update_runs
        activities.each { |act| act.reload }
      end

      it "should create runs for all the activities with the same attributes" do
        activities.each do |act|
          act.runs.each do |run|
            run.sequence_run.should    == subject
            run.remote_endpoint.should == subject.remote_endpoint
            run.remote_id.should       == subject.remote_id
            run.user.should            == subject.user
            run.sequence.should        == subject.sequence
          end
        end
      end
    end

    describe "when all of the activities have prior runs for this sequence" do
      subject { existing_seq_run }

      before(:each) do
        activities.each { |act| act.runs<<FactoryGirl.create(:run, :sequence_run => subject)}
        subject.make_or_update_runs
        activities.each { |act| act.reload }
      end

      it "should reuse the existing runs, without creating new ones" do
        activities.each do |act|
          act.runs.should have(1).run
          act.runs.each do |run|
            run.sequence_run.should == subject
          end
        end
      end
    end

    describe "when the activities have runs outside of the sequence" do
      subject { existing_seq_run }

      before(:each) do
        activities.each { |act| act.runs<<FactoryGirl.create(:run)}
        activities.each { |act| act.reload }
      end

      it "should leave the existing runs alone, and create new ones for the sequence run" do
        activities.each { |act| act.runs.size.should == 1 }
        subject.make_or_update_runs
        activities.each do |act|
          act.reload
          act.runs.size.should == 2
          act.runs.select{ |r| r.sequence_run == subject }.should have(1).match
        end
      end
    end

  end

end
