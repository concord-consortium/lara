require 'spec_helper'

describe Embeddable::LabbookAnswer do
  it_behaves_like 'an answer'

  let(:labbook) { Embeddable::Labbook.create }
  let(:run) { Run.new }
  let(:labbok_answer) { Embeddable::LabbookAnswer.create(question: labbook, run: run) }

  describe '#portal_hash' do
    let(:expected_hash) do
      {
        type:          'external_link',
        question_type: 'iframe interactive',
        question_id:   labbook.portal_id,
        answer:        labbok_answer.view_url,
        is_final:      false
      }
    end

    it 'matches the expected hash' do
      expect(labbok_answer.portal_hash).to eq(expected_hash)
    end
  end
end
