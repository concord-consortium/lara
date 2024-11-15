require 'spec_helper'

describe Embeddable::MultipleChoiceAnswer do
  let(:feedback) { "feedback text" }
  let(:a1)       { FactoryGirl.create(:multiple_choice_choice, choice: "answer_one") }
  let(:a2)       { FactoryGirl.create(:multiple_choice_choice, choice: "answer_two", prompt: feedback) }
  let(:question) { FactoryGirl.create(:multiple_choice, choices: [a1, a2]) }
  let(:run)      { FactoryGirl.create(:run, activity: FactoryGirl.create(:activity) ) }
  let(:answer)   { FactoryGirl.create(:multiple_choice_answer,
                    answers: [a1, a2],
                    question: question,
                    run: run)
                  }

  it_behaves_like "an answer"

  describe "model associations" do
    it "should belong to a multiple choice" do
      expect(answer.question).to eq(question)
      expect(question.answers).to include answer
    end

    it "should belong to a run" do
      expect(answer.run).to eq(run)
      expect(run.multiple_choice_answers).to include answer
    end

    it "should have answers" do
      [a1,a2].each do |a|
        expect(answer.answers).to include a
      end
    end
  end

  describe '#portal_hash' do
    let(:expected) {
                    {
                      "type"         => "multiple_choice",
                      "question_id"  => question.id.to_s,
                      "answer_ids"   => [a1.id.to_s],
                      "answer_texts" => [a1.choice],
                      "is_final"     => answer.is_final
                    }
                   }

    it "serializes to expected JSON" do
      answer.answers = [a1]
      expect(answer.portal_hash).to eq(expected)
    end
  end

  describe "#copy_answer!" do
    let(:another_answer) do
      FactoryGirl.create(:multiple_choice_answer,
        answers: [a1],
        question: question
      )
    end

    it "should copy basic attributes that can be modified by student" do
      answer.copy_answer!(another_answer)
      expect(answer.answer_texts).to eq(another_answer.answer_texts)
    end
  end

  describe '#update_from_form_params' do
    before(:each) do
      answer.answers = []
    end

    it 'turns an array of choice IDs into an array of choices' do
      answer.update_from_form_params( { answers: [a1.id, a2.id] } )
      expect(answer.answers).to include a1
      expect(answer.answers).to include a2
    end

    it 'turns a single choice ID into an array with one choice' do
      answer.update_from_form_params( { answers: a1.id } )
      expect(answer.answers).to include a1
      expect(answer.answers).not_to include a2
    end

    it 'turns an empty ID into an empty array' do
      answer.update_from_form_params( { answers: nil } )
      expect(answer.answers).not_to include a1
      expect(answer.answers).not_to include a2
    end
  end

  describe '#feedback_text' do
    it 'should return choice prompt text when answer is provided' do
      answer.answers = [a2]
      expect(answer.feedback_text).to eql(feedback)
    end
    it 'should return nil when answer is not provided' do
      answer.answers = []
      expect(answer.feedback_text).to be_nil
    end
  end

  describe 'feedback functionality' do
    subject { answer }
    it { is_expected.to respond_to :save_feedback }
    it { is_expected.to respond_to :get_saved_feedback }
    # required interface:
    it { is_expected.to respond_to :answer_text }
    it { is_expected.to respond_to :feedback_text }
  end

  describe "delegated methods" do
    let (:question) { mock_model(Embeddable::MultipleChoice) }

    before(:each) do
      answer.question = question
    end

    describe "choices" do
      it "should delegate to question" do
        expect(question).to receive(:choices).and_return(:some_choices)
        expect(answer.choices).to eq(:some_choices)
      end
    end

    describe "prompt" do
      it "should delegate to question" do
        expect(question).to receive(:prompt).and_return(:some_prompt)
        expect(answer.prompt).to eq(:some_prompt)
      end
    end

    describe 'name' do
      it 'should delegate to question' do
        expect(question).to receive(:name).and_return(:string)
        expect(answer.name).to eq(:string)
      end
    end

    describe 'enable_check_answer' do
      it 'should delegate to question' do
        expect(question).to receive(:enable_check_answer).and_return(true)
        expect(answer.enable_check_answer).to be_truthy
      end
    end

    describe 'multi_answer' do
      it 'should delegate to question' do
        expect(question).to receive(:multi_answer).and_return(true)
        expect(answer.multi_answer).to be_truthy
      end
    end

    describe 'show_as_menu' do
      it 'should delegate to question' do
        expect(question).to receive(:show_as_menu).and_return(true)
        expect(answer.show_as_menu).to be_truthy
      end
    end
  end
end
