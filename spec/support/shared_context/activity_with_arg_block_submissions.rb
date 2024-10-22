shared_context "activity with arg block submissions" do
  let(:user)        { FactoryGirl.create(:author) }
  let(:act)         { FactoryGirl.create(:activity_with_page, user: user, sequences: [sequence]) }
  let(:sequence_id) { sequence.id }
  let(:sequence)    { FactoryGirl.create(:sequence, user: user)}
  let(:page)        { act.pages.first }
  let(:sequence_id) { sequence.id }

  before(:each) do
    # Setup run.
    @run = FactoryGirl.create(:run, activity: act, sequence_id: sequence_id, page: page, remote_endpoint: 'http://remote.endpoint')
    # Setup arg block embeddables.
    @q1 = FactoryGirl.create(:mc_embeddable, prompt: 'q1')
    @q2 = FactoryGirl.create(:open_response, prompt: 'q2')
    @q3 = FactoryGirl.create(:mc_embeddable, prompt: 'q3')
    @q4 = FactoryGirl.create(:open_response, prompt: 'q4')
    allow_any_instance_of(InteractivePage).to receive(:show_arg_block).and_return(true)
    page.show_arg_block
    page.add_embeddable(@q1, 1, 'arg_block')
    page.add_embeddable(@q2, 2, 'arg_block')
    page.add_embeddable(@q3, 3, 'arg_block')
    page.add_embeddable(@q4, 4, 'arg_block')
    # Setup answers.
    # Note that we can ignore actual answer text, as it will be provided in fake feedback items.
    @a1 = FactoryGirl.create(:multiple_choice_answer, run: @run, question: @q1)
    @a2 = FactoryGirl.create(:or_answer, run: @run, question: @q2)
    @a3 = FactoryGirl.create(:multiple_choice_answer, run: @run, question: @q3)
    @a4 = FactoryGirl.create(:or_answer, run: @run, question: @q4)
    # Setup submission.
    @submission = FactoryGirl.create(:c_rater_feedback_submission, interactive_page: page, run: @run, usefulness_score: 10)
    # Setup feedback items.
    @f1 = FactoryGirl.create(:feedback_item, answer: @a1, answer_text: 'text1', feedback_text: 'feedback1', score: 1, feedback_submission: @submission)
    @f2 = FactoryGirl.create(:c_rater_feedback_item, answer: @a2, answer_text: 'text2', feedback_text: 'feedback2', score: 2, feedback_submission: @submission)
    @f3 = FactoryGirl.create(:feedback_item, answer: @a3, answer_text: 'text3', feedback_text: 'feedback3', score: 3, feedback_submission: @submission)
    @f4 = FactoryGirl.create(:c_rater_feedback_item, answer: @a4, answer_text: 'text4', feedback_text: 'feedback4', score: 4, feedback_submission: @submission)
  end
end
