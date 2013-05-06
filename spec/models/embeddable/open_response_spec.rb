require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  let (:open_response) { FactoryGirl.create(:or_embeddable) }

  it "should create a new instance with default values" do
    open_response.should be_valid
  end

  it 'has a self-generated storage key' do
    open_response.storage_key.should_not be_nil
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = { name: open_response.name, prompt: open_response.prompt }
      open_response.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      open_response.duplicate.should be_a_new(Embeddable::OpenResponse).with( name: open_response.name, prompt: open_response.prompt )
    end
  end
end
