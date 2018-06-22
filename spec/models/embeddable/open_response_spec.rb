require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  it_behaves_like "a question"

  let (:open_response) { FactoryGirl.create(:or_embeddable) }

  it "should create a new instance with default values" do
    expect(open_response).to be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = {
        name: open_response.name,
        prompt: open_response.prompt,
        is_prediction: open_response.is_prediction,
        give_prediction_feedback: open_response.give_prediction_feedback,
        prediction_feedback: open_response.prediction_feedback,
        default_text: open_response.default_text,
        is_hidden: open_response.is_hidden,
        is_featured: open_response.is_featured,
        hint: open_response.hint
      }
      expect(open_response.to_hash).to eq(expected)
    end
  end

  describe "export" do
    let(:json){ emb.export.as_json }
    let(:emb) { open_response}
    it 'preserves is_hidden' do
      emb.is_hidden = true
      expect(json['is_hidden']).to eq true
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(open_response.duplicate).to be_a_new(Embeddable::OpenResponse).with( name: open_response.name, prompt: open_response.prompt, default_text: open_response.default_text )
    end
  end

  describe 'C-Rater functionality' do
    subject { open_response }
    it { is_expected.to respond_to(:c_rater_item_settings) }
  end
end
