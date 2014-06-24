require 'spec_helper'

describe Embeddable::MultipleChoiceAnswer do
  let(:a1)       { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_one") }
  let(:a2)       { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_two") }
  let(:question) { FactoryGirl.create(:multiple_choice, :choices => [a1, a2]) }
  let(:run)      { FactoryGirl.create(:run, :activity => FactoryGirl.create(:activity) ) }
  let(:answer)   { FactoryGirl.create(:multiple_choice_answer,
                    :answers  => [a1, a2],
                    :question => question,
                    :run => run)
                  }

  it_behaves_like "an answer"

  describe "model associations" do
    it "should belong to a multiple choice" do
      answer.question.should == question
      question.answers.should include answer
    end

    it "should belong to a run" do
      answer.run.should == run
      run.multiple_choice_answers.should include answer
    end

    it "should have answers" do
      [a1,a2].each do |a|
        answer.answers.should include a
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
      answer.portal_hash.should == expected
    end
  end

  describe '#update_from_form_params' do
    before(:each) do
      answer.answers = []
    end

    it 'turns an array of choice IDs into an array of choices' do
      answer.update_from_form_params( { :answers => [a1.id, a2.id] } )
      answer.answers.should include a1
      answer.answers.should include a2
    end

    it 'turns a single choice ID into an array with one choice' do
      answer.update_from_form_params( { :answers => a1.id } )
      answer.answers.should include a1
      answer.answers.should_not include a2
    end

    it 'turns an empty ID into an empty array' do
      answer.update_from_form_params( { :answers => nil } )
      answer.answers.should_not include a1
      answer.answers.should_not include a2
    end
  end

  describe "delegated methods" do
    let (:question) { mock_model(Embeddable::MultipleChoice) }

    before(:each) do
      answer.question = question
    end

    describe "choices" do
      it "should delegate to question" do
        question.should_receive(:choices).and_return(:some_choices)
        answer.choices.should == :some_choices
      end
    end

    describe "prompt" do
      it "should delegate to question" do
        question.should_receive(:prompt).and_return(:some_prompt)
        answer.prompt.should == :some_prompt
      end
    end

    describe 'name' do
      it 'should delegate to question' do
        question.should_receive(:name).and_return(:string)
        answer.name.should == :string
      end
    end

    describe 'enable_check_answer' do
      it 'should delegate to question' do
        question.should_receive(:enable_check_answer).and_return(true)
        answer.enable_check_answer.should be_true
      end
    end

    describe 'multi_answer' do
      it 'should delegate to question' do
        question.should_receive(:multi_answer).and_return(true)
        answer.multi_answer.should be_true
      end
    end

    describe 'show_as_menu' do
      it 'should delegate to question' do
        question.should_receive(:show_as_menu).and_return(true)
        answer.show_as_menu.should be_true
      end
    end
  end
end
