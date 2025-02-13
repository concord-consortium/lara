require 'spec_helper'

describe Embeddable::ImageQuestionAnswer do
  let(:question){ FactoryBot.create(:image_question) }
  let(:run)     { FactoryBot.create(:run, activity: FactoryBot.create(:activity) ) }

  let(:answer)  do
    FactoryBot.create(:image_question_answer,
      question: question,
      run: run )
  end

  it_behaves_like "an answer"

  describe "model associations" do
    it "should belong to an image question" do
      answer.question = question
      answer.save
      expect(answer.reload.question).to eq(question)
      expect(question.reload.answers).to include answer
    end

    it "should belong to a run" do
      expect(answer.reload.run).to eq(run)
      expect(run.reload.image_question_answers).to include answer
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
          "image_url"   => answer.annotated_image_url
        }
      end

      it "matches the expected hash" do
        expect(answer.portal_hash).to eq(expected)
      end
    end

    describe 'with an annotated_image_url' do
      let(:answer) do
        FactoryBot.create(:image_question_answer,
          question: question,
          annotated_image_url: 'http://annotation.com/foo.png',
          run: run )
      end
      let(:expected) do
        {
          "type"        => "image_question",
          "question_id" => question.id.to_s,
          "answer"      => answer.answer_text,
          "is_final"    => answer.is_final,
          "image_url"   => answer.annotated_image_url
        }
      end

      it "matches the expected hash" do
        expect(answer.portal_hash).to eq(expected)
      end
    end
  end

  describe '#copy_answer!' do
    let(:another_answer) do
      FactoryBot.create(:image_question_answer,
        answer_text: "a",
        image_url: "b",
        annotated_image_url: "c",
        annotation: "d",
        is_final: true
      )
    end

    it "should copy basic attributes that can be modified by student" do
      answer.copy_answer!(another_answer)
      expect(answer.answer_text).to eq(another_answer.answer_text)
      expect(answer.image_url).to eq(another_answer.image_url)
      expect(answer.annotated_image_url).to eq(another_answer.annotated_image_url)
      expect(answer.annotation).to eq(another_answer.annotation)
      expect(answer.is_final).to eq(another_answer.is_final)
    end
  end


  describe "delegated methods" do
    before(:each) do
      @question = mock_model(Embeddable::ImageQuestion)
      answer.question = @question
    end

    describe "prompt" do # And name
      it "should delegate to question" do
        expect(@question).to receive(:prompt).and_return(:some_prompt)
        expect(answer.prompt).to eq(:some_prompt)
      end
    end

    describe 'is_shutterbug?' do # And similar methods for the bg_source attribute
      it "should delegate to question" do
        expect(@question).to receive(:is_shutterbug?).and_return(true)
        expect(answer.is_shutterbug?).to be_truthy
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
        expect(@question).to receive(:is_drawing?).and_return(false)
        expect(answer.require_image_url).to eq(true)
      end
    end
    describe "a drawing" do

      describe "if there is a background image" do
        it "sould return true" do
          expect(@question).to receive(:is_drawing?).and_return(true)
          expect(@question).to receive(:bg_url).and_return("something")
          expect(answer.require_image_url).to eq(true)
        end
      end
      describe "if there is no background image" do
        it "sould return false" do
          expect(@question).to receive(:is_drawing?).and_return(true)
          expect(@question).to receive(:bg_url).and_return("")
          expect(answer.require_image_url).to eq(false)
        end
      end

    end
  end
end
