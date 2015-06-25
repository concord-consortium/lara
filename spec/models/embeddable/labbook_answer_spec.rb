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
        answer:        labbok_answer.report_url,
        is_final:      false
      }
    end

    it 'matches the expected hash' do
      expect(labbok_answer.portal_hash).to eq(expected_hash)
    end
  end

  describe '#copy_answer!' do
    let(:another_answer) { Embeddable::LabbookAnswer.new(run: run) }
    let(:labbook_replace_url) { "#{Embeddable::LabbookAnswer.labbook_provider}/albums/replace_all_snapshots"}

    before(:each) do
      stub_request(:post, labbook_replace_url).
         with(body: {dst_source: Embeddable::LabbookAnswer::SOURCE_ID,
                     dst_user_id: labbok_answer.labbook_user_id,
                     src_source: Embeddable::LabbookAnswer::SOURCE_ID,
                     src_user_id: another_answer.labbook_user_id}).
         to_return(:status => 200, :body => "", :headers => {})
    end

    it 'should fire off a web request to replace album snapshots' do
      labbok_answer.copy_answer!(another_answer)
      expect(a_request(:post, labbook_replace_url)).to have_been_made.once
    end
  end

  describe '#show_in_runtime?' do
    describe 'with a disabled labbok' do
      let(:labbook) { stub_model(Embeddable::Labbook, show_in_runtime?: false) }
      it "should return false" do
        expect(labbok_answer.show_in_runtime?).to eql(false)
      end
    end
    describe 'with an enabled labbok' do
      let(:labbook) { stub_model(Embeddable::Labbook, show_in_runtime?: true) }
      it "should return false" do
        expect(labbok_answer.show_in_runtime?).to eql(true)
      end
    end
  end
end
