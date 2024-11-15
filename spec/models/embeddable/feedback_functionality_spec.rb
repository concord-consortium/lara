require 'spec_helper'

describe Embeddable::FeedbackFunctionality do
  class EmbeddableFeedbackFunctionalityTestClass < ApplicationRecord
    # Well, it's not pretty, but I don't have idea how to solve that better. The goal is to test FeedbackFunctionality
    # isolated from the class that includes it.
    self.table_name = :embeddable_open_response_answers
    include Embeddable::FeedbackFunctionality
  end

  let(:answer) do
    ans = EmbeddableFeedbackFunctionalityTestClass.create
    # Stub interface required by feedback functionality:
    allow(ans).to receive(:answer_text).and_return(ans_text)
    allow(ans).to receive(:feedback_text).and_return(fb_text)
    ans
  end

  let(:ans_text) { 'foobar' }
  let(:fb_text) { 'feedback on foobar' }

  describe 'instance of class that includes feedback functionality' do
    subject { answer }

    it { is_expected.to respond_to(:save_feedback) }
    it { is_expected.to respond_to(:get_saved_feedback) }

    describe '#save_feedback' do
      it 'creates feedback entry in DB (success)' do
        expect(answer.feedback_items.count).to eql(0)
        feedback = answer.save_feedback
        expect(feedback.answer_text).to eql(ans_text)
        expect(feedback.feedback_text).to eql(fb_text)
        expect(answer.feedback_items.count).to eql(1)
      end

      it 'creates multiple feedback entries in DB when called multiple times' do
        answer.save_feedback
        answer.save_feedback
        answer.save_feedback
        expect(answer.feedback_items.count).to eql(3)
      end
    end

    describe '#get_saved_feedback' do
      it 'returns nil when there are no feedback items available' do
        feedback = answer.get_saved_feedback
        expect(feedback).to be_nil
      end

      it 'returns the last feedback item if answer text is unchanged' do
        feedback = answer.save_feedback
        expect(answer.get_saved_feedback).to eql(feedback)
      end
    end
  end
end
