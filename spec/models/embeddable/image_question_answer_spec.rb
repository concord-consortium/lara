require 'spec_helper'

describe Embeddable::ImageQuestionAnswer do
  let(:question){ FactoryGirl.create(:image_question) }
  let(:run)     { FactoryGirl.create(:run, :activity => FactoryGirl.create(:activity) ) }

  let(:answer)  do
    FactoryGirl.create(:image_question_answer,
      :question    => question,
      :run => run )
  end

  it_behaves_like "an answer"

  describe "model associations" do
    it "should belong to an image question" do
      answer.question = question
      answer.save
      answer.reload.question.should == question
      question.reload.answers.should include answer
    end

    it "should belong to a run" do
      answer.reload.run.should == run
      run.reload.image_question_answers.should include answer
    end
  end

  describe '#portal_hash' do
    describe 'without an annotated_image_url' do
      let(:expected) do
        {
          "type"        => "image_question",
          "question_id" => question.id.to_s,
          "answer"      => answer.answer_text,
          "image_url"   => answer.image_url,
          "annotation"  => nil
        }
      end

      it "matches the expected hash" do
        answer.portal_hash.should == expected
      end
    end

    describe 'with an annotated_image_url' do
      let(:answer) do
        FactoryGirl.create(:image_question_answer,
          :question    => question,
          :annotated_image_url => 'http://annotation.com/foo.png',
          :run => run )
      end
      let(:expected) do
        {
          "type"        => "image_question",
          "question_id" => question.id.to_s,
          "answer"      => answer.answer_text,
          "image_url"   => answer.annotated_image_url,
          "annotation"  => nil
        }
      end

      it "matches the expected hash" do
        answer.portal_hash.should == expected
      end
    end
  end

  describe "delegated methods" do
    before(:each) do
      @question = mock_model(Embeddable::ImageQuestion)
      answer.question = @question
    end

    describe "prompt" do # And name
      it "should delegate to question" do
        @question.should_receive(:prompt).and_return(:some_prompt)
        answer.prompt.should == :some_prompt
      end
    end

    describe 'is_shutterbug?' do # And similar methods for the bg_source attribute
      it "should delegate to question" do
        @question.should_receive(:is_shutterbug?).and_return(true)
        answer.is_shutterbug?.should be_true
      end
    end
  end

end
