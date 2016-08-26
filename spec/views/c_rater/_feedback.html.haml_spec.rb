require 'spec_helper'

#NOTE: You can look at the styles for this feedback by browsing /dev/test_argblock

describe "Rendering Feedback scores" do #

  let(:max_score) { 4 }
  let(:score)     { 3 }
  let(:feedback_stubs) do
    {
      feedback_text: "Feedback Text",
      outdated?: false,
      error?: false,
      score: score,
      max_score: max_score
    }
  end
  let(:feedback) { double(feedback_stubs)}

  before(:each) do
    render partial: "c_rater/argumentation_block/feedback", locals: {feedback: feedback, emb_id: 1}
  end

  describe "feedback_item partial styles" do
    it "should be a feedback item" do
      expect(rendered).to have_css(".ab-feedback-item")
    end
    describe "with a max score of 4" do
      let(:max_score) { 4 }
      it "should have the correct CSS" do
        expect(rendered).to have_css(".max-score-4")
      end
      describe "a score of 0" do
        let(:score)     { 0 }
        it "should have the correct CSS" do
          expect(rendered).to have_css(".score-0")
        end
      end
      describe "a score of 4" do
        let(:score)     { 4 }
        it "should have the correct CSS" do
          expect(rendered).to have_css(".score-4")
        end
      end
    end
    describe "with a max score of 6" do
      let(:max_score) { 6 }
      it "should have the correct CSS" do
        expect(rendered).to have_css(".max-score-6")
      end
      describe "a score of 0" do
        let(:score)     { 0 }
        it "should have the correct CSS" do
          expect(rendered).to have_css(".score-0")
        end
      end
      describe "a score of 6" do
        let(:score)     { 6 }
        it "should have the correct CSS" do
          expect(rendered).to have_css(".score-6")
        end
      end
    end
  end


end
