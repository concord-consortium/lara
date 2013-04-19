require 'spec_helper'

describe Embeddable::MultipleChoiceAnswer do
  before(:each) do
    @a1 = {:text => "answer_one", :id => 1}
    @a2 = {:text => "answer_two", :id => 2}
    @answer   = Embeddable::MultipleChoiceAnswer.create({
      :answer_texts          => [@a1[:text], @a2[:text]],
      :answer_ids            => [@a1[:id],   @a2[:id]  ]
    })
  end

  describe "model associations" do
    it "should belong to a multipe choice" do
      @answer.question = question = FactoryGirl.create(:multiple_choice)
      @answer.save
      @answer.reload.question.should == question
      question.reload.answers.should include @answer
    end

    it "should belong to a run" do
      run = Run.create(:activity => FactoryGirl.create(:activity))
      @answer.run = run
      @answer.save
      @answer.reload.run.should == run
      run.reload.multiple_choice_answers.should include @answer
    end
  end

  describe "model serializations" do
    it "should unpack answer_texts" do
      [@a1,@a2].each do |a|
        @answer.reload.answer_texts.should include a[:text]
      end
    end
    it "should unpack answer_ids" do
      [@a1,@a2].each do |a|
        @answer.reload.answer_ids.should include a[:id]
      end
    end
  end

  describe "delegated methods" do
    describe "choices" do
      it "should delegate to question" do
        question = mock_model(Embeddable::MultipleChoice)
        question.should_receive(:choices).and_return(:some_choices)
        @answer.question = question
        @answer.choices.should == :some_choices
      end
    end

    describe "prompt" do
      it "should delegate to question" do
        question = mock_model(Embeddable::MultipleChoice)
        question.should_receive(:prompt).and_return(:some_prompt)
        @answer.question = question
        @answer.prompt.should == :some_prompt
      end
    end

  end
end
