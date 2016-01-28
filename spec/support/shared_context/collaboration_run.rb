shared_context "collaboration run" do
  let(:user1)    { FactoryGirl.create(:user) }
  let(:user2)    { FactoryGirl.create(:user) }
  let(:user3)    { FactoryGirl.create(:user) }
  let(:activity) { FactoryGirl.create(:activity_with_page_and_or) }
  # There is no need to test other types of questions, as answer copying / duplication is handled
  # in their separate unit tests.
  let(:or_question) { activity.questions[0] }
  let(:or_answer1)  { FactoryGirl.create(:or_answer, { answer_text: "the answer", question: or_question }) }
  let(:or_answer2)  { FactoryGirl.create(:or_answer, { answer_text: "the different answer", question: or_question }) }

  let(:run1) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user1
    r.save!
    r
  }
  let(:finder1) { Embeddable::AnswerFinder.new(run1) }
  let(:run2) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user2
    r.save!
    r
  }
  let(:finder2) { Embeddable::AnswerFinder.new(run2) }
  let(:run3) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user3
    r.save!
    r
  }
  let(:finder3) { Embeddable::AnswerFinder.new(run3) }
  let(:collaboration_run) {
    cr = FactoryGirl.create(:collaboration_run)
    cr.user = user1
    cr.save!
    cr
  }

  before(:each) do
    collaboration_run.runs << run1
    collaboration_run.runs << run2
    collaboration_run.runs << run3
  end
end
