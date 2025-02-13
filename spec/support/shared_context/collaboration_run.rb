shared_context "collaboration run" do
  let(:user1)    { FactoryBot.create(:user) }
  let(:user2)    { FactoryBot.create(:user) }
  let(:user3)    { FactoryBot.create(:user) }
  let(:activity) { FactoryBot.create(:activity_with_page_and_or) }
  # There is no need to test other types of questions, as answer copying / duplication is handled
  # in their separate unit tests.
  let(:or_question) { activity.reportable_items[0] }
  let(:or_answer1)  { FactoryBot.create(:or_answer, { answer_text: "the answer", question: or_question }) }
  let(:or_answer2)  { FactoryBot.create(:or_answer, { answer_text: "the different answer", question: or_question }) }

  let(:run1) {
    r = FactoryBot.create(:run)
    r.activity = activity
    r.user = user1
    r.save!
    r
  }
  let(:finder1) { Embeddable::AnswerFinder.new(run1) }
  let(:run2) {
    r = FactoryBot.create(:run)
    r.activity = activity
    r.user = user2
    r.save!
    r
  }
  let(:finder2) { Embeddable::AnswerFinder.new(run2) }
  let(:run3) {
    r = FactoryBot.create(:run)
    r.activity = activity
    r.user = user3
    r.save!
    r
  }
  let(:finder3) { Embeddable::AnswerFinder.new(run3) }
  let(:collaboration_run) {
    cr = FactoryBot.create(:collaboration_run)
    cr.user = user1
    cr.save!
    cr
  }

  def setup_collaboration_run
    collaboration_run.runs << run1
    collaboration_run.runs << run2
    collaboration_run.runs << run3
  end
end
