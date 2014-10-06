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
          "is_final"    => answer.is_final,
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
          "is_final"    => answer.is_final,
          "image_url"   => answer.annotated_image_url,
          "annotation"  => nil
        }
      end

      it "matches the expected hash" do
        answer.portal_hash.should == expected
      end
    end
  end

  describe '#copy_answer!' do
    let(:another_answer) do
      FactoryGirl.create(:image_question_answer,
        :answer_text => "a",
        :image_url => "b",
        :annotated_image_url => "c",
        :annotation => "d",
        :is_final => true
      )
    end

    it "should copy basic attributes that can be modified by student" do
      answer.copy_answer!(another_answer)
      answer.answer_text.should == another_answer.answer_text
      answer.image_url.should == another_answer.image_url
      answer.annotated_image_url.should == another_answer.annotated_image_url
      answer.annotation.should == another_answer.annotation
      answer.is_final.should == another_answer.is_final
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

  describe "require_image_url" do
    before(:each) do
      @question = mock_model(Embeddable::ImageQuestion)
      answer.question = @question
    end

    describe "a snapshot" do
      it "sould always be true" do
        @question.should_receive(:is_drawing?).and_return(false)
        answer.require_image_url.should == true
      end
    end
    describe "a drawing" do

      describe "if there is a background image" do
        it "sould return true" do
          @question.should_receive(:is_drawing?).and_return(true)
          @question.should_receive(:bg_url).and_return("something")
          answer.require_image_url.should == true
        end
      end
      describe "if there is no background image" do
        it "sould return false" do
          @question.should_receive(:is_drawing?).and_return(true)
          @question.should_receive(:bg_url).and_return("")
          answer.require_image_url.should == false
        end
      end

    end
  end
end
