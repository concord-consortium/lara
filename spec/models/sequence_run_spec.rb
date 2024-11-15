require 'spec_helper'

# syntax-sugar for forcing a let expression to evaluate
def make(thing) end

describe SequenceRun do
  let(:user)            { FactoryGirl.create(:user)            }
  let(:sequence)        { FactoryGirl.create(:sequence)        }
  let(:remote_endpoint) { "http://someplace.com/return_data/4" }
  let(:remote_id)       { "23" }

  let(:portal) do
    double("portal",
      remote_endpoint: remote_endpoint,
      remote_id: remote_id,
      platform_info: {},
      valid?: true)
  end

  let(:existing_seq_run) do
    SequenceRun.create!(
      sequence_id: sequence.id,
      user_id: user.id,
      remote_endpoint: remote_endpoint,
      remote_id: remote_id)
  end


  describe "class methods" do
    subject { SequenceRun }

    describe "lookup_or_create" do

      before(:each) { make existing_seq_run }

      describe "when the user has already run the sequence from the same portal" do
        it "should return the existing run" do
          expect(subject.lookup_or_create(sequence, user, portal)).to eq(existing_seq_run)
        end
      end

      describe "when the sequence isn't the same as the existing" do
        let(:other_sequence) { FactoryGirl.create(:sequence)  }
        it "should make a new run" do
          expect(subject.lookup_or_create(other_sequence, user, portal)).not_to eq(existing_seq_run)
        end
      end

      describe "when the user isn't the same as the existing" do
        let(:other_user) { FactoryGirl.create(:user) }
        it "should make a new run" do
          expect(subject.lookup_or_create(sequence, other_user, portal)).not_to eq(existing_seq_run)
        end
      end

      describe "when the portal isn't the same as the existing" do
        let(:other_portal) {
          double("portal",
            remote_id: "something_else",
            remote_endpoint: remote_endpoint,
            platform_info: {},
            valid?: true) }
        it "should make a new run" do
          expect(subject.lookup_or_create(sequence, user, other_portal)).not_to eq(existing_seq_run)
        end
      end

      describe "when platform info is provided" do
        let(:portal) {
          double("portal",
            remote_endpoint: remote_endpoint,
            remote_id: remote_id,
            platform_info: { platform_id: "test_platform" },
            valid?: true
          )
        }
        it "should save it" do
          expect(subject.lookup_or_create(sequence, user, portal).platform_id).to eq("test_platform")
        end
      end
    end
  end

  describe "run_for_activity" do
    subject            { existing_seq_run }

    let(:activity1) { FactoryGirl.create(:activity) }
    let(:activity2) { FactoryGirl.create(:activity) }
    let(:outside_activity) { FactoryGirl.create(:activity) }
    let(:sequence) { FactoryGirl.create(:sequence,
      lightweight_activities: [activity1, activity2])}
    let(:activity_run_in_seq_run) { FactoryGirl.create(:run,
        user: user,
        activity: activity1,
        # TODO:  The current implementation looks up the sequence runs
        # this way.  We may want to look them up using other means.
        sequence_run: existing_seq_run)
      }

    describe "when there is no existing run for an activity in the sequence" do
      it "should create one" do
        expect(subject.runs.count).to eq 0
        expect(subject.run_for_activity(activity2)).to_not be_nil
        expect(subject.runs.count).to eq 1
      end
    end

    describe "when there is no existing run for an activity not in the sequence" do
      it "should raise an exception" do
        expect{subject.run_for_activity(activity3)}.to raise_error(Exception)
      end
    end

    describe "when there is already a run for an activity for that sequence_run" do

      it "should return the existing run" do
        make activity_run_in_seq_run
        expect(subject.run_for_activity(activity1)).to eq(activity_run_in_seq_run)
      end
    end
  end


  describe "an activity run for a sequence of 4 acitivites" do
    subject          { existing_seq_run }

    let(:activities) { Array(1..4).map { |a| FactoryGirl.create(:activity)} }
    let(:sequence)   { FactoryGirl.create(:sequence, lightweight_activities: activities) }

    describe "most_recent_run" do
      before(:each) do
        subject.make_or_update_runs
        runs = subject.runs
        runs.each { |r| r.update_attribute(:updated_at, 10.days.ago) }
        runs[2].update_attribute(:updated_at, 1.day.ago)
        @most_recent = runs[2]
        subject.reload
      end

      it "should return the most recently run activity" do
        expect(subject.most_recent_run).to eq(@most_recent)
      end
    end


    describe "has_been_run" do
      let(:mock_runs){ Array(1..4).map {|a| double(has_been_run: false) }}
      describe "when none of the activities have been run" do
        it "should report false" do
          allow(subject).to receive_messages(runs: mock_runs)
          expect(subject.has_been_run).to be_falsey
        end
      end
      describe "when at least one of the activities has been run" do
        it "should report true" do
          allow(mock_runs[2]).to receive_messages(has_been_run: true)
          allow(subject).to receive_messages(runs: mock_runs)
          expect(subject.has_been_run).to be_truthy
        end
      end
    end

    describe "make_or_update_runs" do
      describe "when none of the activities have been previously run" do
        before(:each) do
          activities.each { |act| expect(act.runs).to be_empty } # precondition
          subject.make_or_update_runs
          activities.each { |act| act.reload }
        end

        it "should create runs for all the activities with the same attributes" do
          activities.each do |act|
            act.runs.each do |run|
              expect(run.sequence_run).to    eq(subject)
              expect(run.remote_endpoint).to eq(subject.remote_endpoint)
              expect(run.remote_id).to       eq(subject.remote_id)
              expect(run.user).to            eq(subject.user)
              expect(run.sequence).to        eq(subject.sequence)
            end
          end
        end
      end

      describe "when all of the activities have prior runs for this sequence" do
        subject { existing_seq_run }

        before(:each) do
          activities.each { |act| act.runs<<FactoryGirl.create(:run, sequence_run: subject)}
          subject.make_or_update_runs
          activities.each { |act| act.reload }
        end

        it "should reuse the existing runs, without creating new ones" do
          activities.each do |act|
            expect(act.runs.size).to eq(1)
            act.runs.each do |run|
              expect(run.sequence_run).to eq(subject)
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
          activities.each { |act| expect(act.runs.size).to eq(1) }
          subject.make_or_update_runs
          activities.each do |act|
            act.reload
            expect(act.runs.size).to eq(2)
            expect(act.runs.select{ |r| r.sequence_run == subject }.size).to eq(1)
          end
        end
      end
    end # make_or_update_runs
  end # a run for a sequence of 4 activities
end
