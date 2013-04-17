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
      question = Embeddable::MultipleChoice.create()
      @answer.question = question
      @answer.save
      @answer.reload.question.should == question
      question.reload.answers.should include @answer
    end

    it "should belong to a run" do
      run = Run.create()
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
end
