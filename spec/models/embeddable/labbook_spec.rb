require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Labbook do
  let(:labbook) { Embeddable::Labbook.new }

  describe '#to_hash' do
    it 'is implemented' do
      expect(labbook).to respond_to(:to_hash)
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(labbook.duplicate).to be_a_new(Embeddable::Labbook)
    end
  end

  describe '#action_label' do
    context 'labbook action type is set to upload' do
      let(:labbook) { Embeddable::Labbook.new(action_type: Embeddable::Labbook::UPLOAD_ACTION) }
      it 'returns "Upload image"' do
        expect(labbook.action_label).to eql(I18n.t('UPLOAD_IMAGE'))
      end
    end
    context 'labbook action type is set to snapshot' do
      let(:labbook) { Embeddable::Labbook.new(action_type: Embeddable::Labbook::SNAPSHOT_ACTION) }
      it 'returns "Take snapshot"' do
        expect(labbook.action_label).to eql(I18n.t('TAKE_SNAPSHOT'))
      end
    end
    context 'labbook has a custom action label defined' do
      let(:label) { 'label abc' }
      let(:labbook) do
        Embeddable::Labbook.new(action_type: Embeddable::Labbook::UPLOAD_ACTION,
                                custom_action_label: label)
      end
      it 'returns custom label' do
        expect(labbook.action_label).to eql(label)
      end
    end
  end
end
