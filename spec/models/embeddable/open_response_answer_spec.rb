require 'spec_helper'

describe Embeddable::OpenResponseAnswer do
  let(:question) { FactoryGirl.create(:or_embeddable) }
  let(:run) { FactoryGirl.create(:run, activity: FactoryGirl.create(:activity) ) }
  let(:answer) { FactoryGirl.create(:or_answer, answer_text: "the answer", question: question, run: run ) }

  it_behaves_like "an answer"
  describe "model associations" do

    it "should belong to an open response" do
      answer.question = question
      answer.save
      expect(answer.reload.question).to eq(question)
      expect(question.reload.answers).to include answer
    end

    it "should belong to a run" do
      expect(answer.reload.run).to eq(run)
      expect(run.reload.open_response_answers).to include answer
    end
  end

  describe '#portal_hash' do
    let(:expected) {
                     {
                        "type"        => "open_response",
                        "question_id" => question.id.to_s,
                        "answer"      => answer.answer_text,
                        "is_final"    => answer.is_final
                      }
                    }

    it "matches the expected hash" do
      expect(answer.portal_hash).to eq(expected)
    end
  end

  describe '#copy_answer!' do
    let(:another_answer) { FactoryGirl.create(:or_answer, answer_text: "the answer", is_final: true) }

    it "should copy basic attributes that can be modified by student" do
      answer.copy_answer!(another_answer)
      expect(answer.answer_text).to eq(another_answer.answer_text)
      expect(answer.is_final).to eq(another_answer.is_final)
    end
  end

  describe "delegated methods" do
    describe "prompt" do
      it "should delegate to question" do
        question = mock_model(Embeddable::OpenResponse)
        expect(question).to receive(:prompt).and_return(:some_prompt)
        answer.question = question
        expect(answer.prompt).to eq(:some_prompt)
      end
    end
  end

  describe "C-Rater functionality" do
    subject { answer }
    it { is_expected.to respond_to(:save_feedback) }
    it { is_expected.to respond_to(:get_saved_feedback) }
    describe "required interface" do
      it { is_expected.to respond_to(:answer_text) }
      it { is_expected.to respond_to(:c_rater_item_settings) }
    end
  end
end
