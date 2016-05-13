require "spec_helper"

describe QuestionTracker::Reporter do

  let(:portal_data) do
    [{
        class_name: class_name,
        class_id: class_id,
        teacher_name: teacher_name,
        teacher_id: teacher_id,
        student_name: student_name1,
        student_id: student_id1,
        endpoints: [ endpoint1, endpoint2 ]
      },
      {
       class_name: class_name,
       class_id: class_id,
       teacher_name: teacher_name,
       teacher_id: teacher_id,
       student_name: student_name2,
       student_id: student_id2,
       endpoints: [ endpoint3 ]
    }]
  end
  let(:class_name)       { "Class 1" }
  let(:class_id)         { "22" }
  let(:teacher_name)     { "Teacher" }
  let(:teacher_id)       { "11" }
  let(:student_name1)    { "student1" }
  let(:student_id1)      { "1" }
  let(:student_email1)   { "fake@blarg.com" }
  let(:student_name2)    { "student2" }
  let(:student_id2)      { "2" }
  let(:student_email2)   { "fake@blarg.com" }
  let(:user)             { FactoryGirl.create(:user, email: student_email1) }
  let(:endpoint1)        { "http://fake.blarg.com/blarg/1" }
  let(:endpoint2)        { "http://fake.blarg.com/blarg/2" }
  let(:endpoint3)        { "http://fake.blarg.com/blarg/3" }
  let(:learner_json)     { portal_data.to_json }
  let(:prompt1)          { "xyzzy" }
  let(:prompt2)          { "xyzzy2" }
  let(:master_question)  { FactoryGirl.create(:open_response, prompt:prompt1) }
  let(:question_tracker) { QuestionTracker.create(master_question:master_question ) }
  let(:reporter)         { QuestionTracker::Reporter.new(question_tracker, learner_json) }

  let(:activity1)         { FactoryGirl.create(:activity, name: "activity 1") }
  let(:page1)             { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
  let(:open_response1)    { FactoryGirl.create(:open_response, prompt:prompt1) }

  let(:activity2)         { FactoryGirl.create(:activity, name: "activity 2") }
  let(:page2)             { FactoryGirl.create(:interactive_page, name: "page 2", position: 0) }
  let(:open_response2)    { FactoryGirl.create(:open_response, prompt:prompt2) }

  before(:each) do
    page1.add_embeddable(open_response1)
    activity1.pages << page1

    page2.add_embeddable(open_response2)
    activity2.pages << page2

    PortalSender::Protocol.any_instance.stub(:post_answers).and_return(true)
  end

  it "exists" do
    expect(reporter).to_not be_nil
  end

  describe "class methods" do
    describe "finding tracked questions with #tracked_questions_for_activity 1" do

      subject { QuestionTracker::Reporter.question_trackers_for_activity(activity1) }

      describe "activity 1 has no tracked questions" do
        it { is_expected.to eql [] }
      end

      describe "activity 1 has tracked questions" do
        before(:each) { question_tracker.add_question(open_response1) }
        it { is_expected.to include question_tracker}
      end
    end
  end

  describe "looking up portal users" do
    it "should have three learners registered" do
      expect(reporter.learner_map.size).to eql 3
    end
  end
  describe "#lookup_user" do
    it "should return the same user for learners of the same student" do
      expect(reporter.lookup_user(endpoint1)).to eql reporter.lookup_user(endpoint2)
    end
    it "should return different users for unrelated endpoints" do
      expect(reporter.lookup_user(endpoint1)).not_to eql reporter.lookup_user(endpoint3)
    end
  end


  describe "finding answers" do
    let(:run)           { Run.create(user: user, activity: activity1, remote_endpoint: endpoint1) }
    let(:question)      { open_response1 }

    def get_answer(_run, _question)
      return Embeddable::AnswerFinder.new(_run).find_answer(_question)
    end

    describe "when the activity has a tracked question" do
      before(:each) { question_tracker.add_question(open_response1) }
      describe "with no answers from the user" do
        describe "the missing answer" do
          subject { get_answer(run, question).answer_text }
          it { is_expected.to be_nil }
        end

        describe "the report" do
          describe "the answers" do
            describe "when no one has answered anything" do
              it "answers should be empty" do
                expect(reporter.answers).to be_empty
              end
            end

            describe "when student answers the tracked question in activity 1" do
              let(:answer_text) { "I answered it" }
              before(:each) do
                a = get_answer(run, question)
                a.update_attribute(:answer_text, answer_text)
              end
              it "user answers should have one serialized answer" do
                expect(reporter.answers.length).to eql 1
                user_answers = reporter.answers[0]
                expect(user_answers["student_name"]).to eql student_name1
                expect(user_answers["student_id"]).to eql student_id1
                expect(user_answers["answer_hash"]["answer"]).to eql answer_text
                expect(user_answers["class_name"]).to eql class_name
                expect(user_answers["class_id"]).to eql class_id
                expect(user_answers["teacher_name"]).to eql teacher_name
                expect(user_answers["teacher_id"]).to eql teacher_id
                expect(user_answers["activity_id"]).to eql activity1.id
                expect(user_answers["activity_name"]).to eql activity1.name
                expect(user_answers["endpoint"]).to eql run.remote_endpoint
              end

              describe "when there is another run by the same student in activty2 with a different endpoint" do
                let(:run2)           { Run.create(user: user, activity: activity2, remote_endpoint: endpoint2) }
                let(:answer_text2) { "I answered it again" }
                before(:each) do
                  a = get_answer(run2, open_response2)
                  a.update_attribute(:answer_text, answer_text2)
                end

                describe "when the question in activity 2 isn't tracked" do
                  it "the report should only show answers for the first activty" do
                    expect(reporter.answers.length).to eql 1
                  end
                end

                describe "When the question of activity 2 is tracked" do
                  before(:each) { question_tracker.add_question(open_response2) }
                  it "the report should show data from both activitities" do
                    user_answers = reporter.answers[1]
                    expect(user_answers["student_name"]).to eql student_name1
                    expect(user_answers["answer_hash"]["answer"]).to eql answer_text2
                    expect(user_answers["class_name"]).to eql class_name
                    expect(user_answers["teacher_name"]).to eql teacher_name
                    expect(user_answers["activity_id"]).to eql activity2.id
                    expect(user_answers["endpoint"]).to eql run2.remote_endpoint
                  end
                end
              end
            end
          end
        end
      end
    end

  end


end