require 'spec_helper'

# This test enforces two CSS selectors that plugins need to wrap content
# in the ArgBlock. See for example the Teacher Edition Plugin
# https://www.pivotaltracker.com/story/show/163959056
# [DL/NP] 2019-03-20

describe "Rended DOM for Argblock sections" do
  let(:page) { double("page double", layout: "big", id: 1) }
  let(:embeddable_class) { double( "Answer Class", name: 'Embeddable::MultipleChoiceAnswer') }
  let(:saved_feedback) do
    double("Saved Feedback",
      feedback_text: "",
      error?: nil,
      outdated?: false,
      max_score: 0,
      score: 0
    )
  end

  let(:embeddable) do
    double("Embeddable",
      class: embeddable_class,
      id: 1,
      question_index: 1,
      get_saved_feedback: saved_feedback,
      answer_id: 1,
      prompt: "what is the answer?",
      embeddable_dom_id: 'foo-dom-id'
    )
  end
  let(:last_sumission){ double("last submission", key: '1' ) }
  let(:embeddables)   { [embeddable] }
  let(:fake_run)      { double("Fake run", key: "111") }

  before(:each) do
    assign(:run, fake_run)
    allow(view).to receive(:arg_block_embeddables).and_return(embeddables)
    allow(view).to receive(:submission_count).and_return(3)
    allow(view).to receive(:last_submission).and_return(nil)
    allow(view).to receive(:form_for).and_return(last_sumission)
    allow(view).to receive(:c_rater_arg_block_save_feedback_path).and_return("fake_path")

    render partial: "c_rater/argumentation_block/runtime", locals: {page: page}

  end

  describe "Structure of the arg-block DOM" do
    it "should follow a standard strucutre needed by plugins for wrapping embeddables" do
      expect(rendered).to have_css("##{embeddable.embeddable_dom_id}.question .embeddable-container")
    end
  end

end
