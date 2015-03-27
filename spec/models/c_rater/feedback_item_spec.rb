require 'spec_helper'

describe CRater::FeedbackItem do
  let(:feedback_item) do
    CRater::FeedbackItem.new(status: CRater::FeedbackItem::STATUS_SUCCESS)
  end

  describe '#successful?' do
    it 'returns true when status is equal to success' do
      expect(feedback_item.successful?).to be true
    end

    it 'returns false when status is different from success' do
      feedback_item.status = CRater::FeedbackItem::STATUS_ERROR
      expect(feedback_item.successful?).to be false
    end
  end

  describe '#error_msg' do
    it 'returns nil when feedback has no errors' do
      expect(feedback_item.error_msg).to be_nil
    end

    it 'returns feedback_text attr value when feedback has errors' do
      feedback_item.status = CRater::FeedbackItem::STATUS_ERROR
      error_msg = 'error msg!'
      feedback_item.feedback_text = error_msg
      expect(feedback_item.error_msg).to eql(error_msg)
    end
  end
end
