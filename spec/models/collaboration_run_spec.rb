require 'spec_helper'

describe CollaborationRun do
  let(:user1)    { FactoryGirl.create(:user) }
  let(:user2)    { FactoryGirl.create(:user) }
  let(:user3)    { FactoryGirl.create(:user) }
  let(:activity) { FactoryGirl.create(:activity) }
  let(:run1) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user1
    r
  }
  let(:finder1) { Embeddable::AnswerFinder.new(run1) }
  let(:run2) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user2
    r
  }
  let(:finder2) { Embeddable::AnswerFinder.new(run2) }
  let(:run3) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user3
    r
  }
  let(:finder3) { Embeddable::AnswerFinder.new(run3) }
  let(:collaboration_run) {
    cr = FactoryGirl.create(:collaboration_run)
    cr.user = user1
    cr.runs << run1
    cr.runs << run2
    cr.runs << run3
    cr
  }
  # There is no need to test other types of questions, as answer copying / duplication is handled
  # in their separate unit tests.
  let(:or_question) { FactoryGirl.create(:or_embeddable) }
  let(:or_answer1)  { FactoryGirl.create(:or_answer, { :answer_text => "the answer", :question => or_question }) }
  let(:or_answer2)  { FactoryGirl.create(:or_answer, { :answer_text => "the different answer", :question => or_question }) }

  describe "class methods" do
    describe "#already_created?" do
      it "should return true if run already exists" do
        CollaborationRun.already_created?(collaboration_run.collaboration_endpoint_url).should == true
      end
    end
    describe "#lookup" do
      it "should return run using endpoint URL" do
        CollaborationRun.lookup(collaboration_run.collaboration_endpoint_url).should == collaboration_run
      end
    end
  end

  describe "#propagate_answer" do
    before do
      # User1 and user2 provided different answers, user3 didn't provide any.
      run1.open_response_answers << or_answer1
      run2.open_response_answers << or_answer2
    end

    it "should copy an answer to all the collaborators runs" do
      run1.open_response_answers.count.should == 1
      run2.open_response_answers.count.should == 1
      run3.open_response_answers.count.should == 0
      # Propagate user1's answer. User2's answer should be overwritten, while answer for user3
      # should be created.
      collaboration_run.propagate_answer(or_answer1)
      run1.open_response_answers.count.should == 1
      run2.open_response_answers.count.should == 1
      run3.open_response_answers.count.should == 1
      finder1.find_answer(or_question).answer_text.should == or_answer1.answer_text
      finder2.find_answer(or_question).answer_text.should == or_answer1.answer_text
      finder3.find_answer(or_question).answer_text.should == or_answer1.answer_text
    end
  end

  describe "#owners_run" do
    it "should return run owned by the collaboration owner" do
      collaboration_run.owners_run(activity).should == run1
    end
  end
end
