require 'spec_helper'

describe CRater::ScoreMapping do
  let(:expected_feedback)  { "feedback" }
  let(:params) { {mapping: {'score4' => expected_feedback }} }

  subject { CRater::ScoreMapping.new(params)}

  describe "max_score" do
    it "should be 4" do
      expect(subject.max_score).to eql 4
    end
  end

  describe "with no mapping" do
    let(:params) {{mapping: {}}}
    it "should be -1" do
      expect(subject.max_score).to eql -1
    end
  end

  describe "method missing methods" do
    describe "score4" do
      it "should be 4" do
        expect(subject.score4).to eql expected_feedback
      end
    end

    # Method missing where mapping doesn't exist:
    describe "score42" do
      it "should be nil" do
        expect(subject.score42).to be_nil
      end
    end
  end

  describe "get_feedback_text" do
    subject { CRater::ScoreMapping.new(params).get_feedback_text(score) }
    describe "with an error result" do
      let(:score) { -1 }
      it { is_expected.to eql I18n.t('ARG_BLOCK.TEST_MODEL') }
    end
    describe "with a configured score" do
      let(:score) { 4 }
      it { is_expected.to eql expected_feedback }
    end
  end

end