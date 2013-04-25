require 'spec_helper'

describe Embeddable::MultipleChoiceAnswer do
  let(:a1)       { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_one") }
  let(:a2)       { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_two") }
  let(:question) { FactoryGirl.create(:multiple_choice, :choices => [a1, a2]) }
  let(:answer)   { FactoryGirl.create(:multiple_choice_answer,
                    :answers  => [a1, a2],
                    :question => question)
                  }

  describe "model associations" do
    it "should belong to a multiple choice" do
      answer.question = question = FactoryGirl.create(:multiple_choice)
      answer.save
      answer.reload.question.should == question
      question.reload.answers.should include answer
    end

    it "should belong to a run" do
      run = Run.create(:activity => FactoryGirl.create(:activity))
      answer.run = run
      answer.save
      answer.reload.run.should == run
      run.reload.multiple_choice_answers.should include answer
    end

    it "should have answers" do
      [a1,a2].each do |a|
        answer.reload.answers.should include a
      end
    end
  end

  describe '#portal_hash' do
    let(:expected) { 
                    { 
                      "type"         => "multiple_choice",
                      "question_id"  => question.id.to_s,
                      "answer_ids"   => [a1.id.to_s],
                      "answer_texts" => [a1.choice]
                    }
                   }

    it "serializes to expected JSON" do
      answer.answers = [a1]
      answer.portal_hash.should == expected
    end
  end

  describe "delegated methods" do
    describe "choices" do
      it "should delegate to question" do
        question = mock_model(Embeddable::MultipleChoice)
        question.should_receive(:choices).and_return(:some_choices)
        answer.question = question
        answer.choices.should == :some_choices
      end
    end

    describe "prompt" do
      it "should delegate to question" do
        question = mock_model(Embeddable::MultipleChoice)
        question.should_receive(:prompt).and_return(:some_prompt)
        answer.question = question
        answer.prompt.should == :some_prompt
      end
    end
  end
end
