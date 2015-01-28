require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  let (:open_response) { FactoryGirl.create(:or_embeddable) }

  it "should create a new instance with default values" do
    expect(open_response).to be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = { name: open_response.name, prompt: open_response.prompt }
      expect(open_response.to_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(open_response.duplicate).to be_a_new(Embeddable::OpenResponse).with( name: open_response.name, prompt: open_response.prompt )
    end
  end
end
