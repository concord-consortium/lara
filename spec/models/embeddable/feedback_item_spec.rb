require 'spec_helper'

describe Embeddable::FeedbackItem do
  let(:answer_text) { 'foobar' }
  let(:answer_double) do
    ans = double('answer')
    allow(ans).to receive(:answer_text).and_return(answer_text)
    ans
  end
  let(:feedback_item) do
    fi = Embeddable::FeedbackItem.new(answer_text: answer_text)
    allow(fi).to receive(:answer).and_return(answer_double)
    fi
  end

  describe '#outdated?' do
    it 'returns false when answer text has not been updated' do
      expect(feedback_item.outdated?).to be false
    end

    it 'returns true when answer text has been updated' do
      allow(answer_double).to receive(:answer_text).and_return('new ans!')
      expect(feedback_item.outdated?).to be true
    end
  end
end