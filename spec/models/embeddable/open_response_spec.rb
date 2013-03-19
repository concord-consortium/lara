require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  let (:open_response) { FactoryGirl.create(:or_embeddable) }

  it "should create a new instance with default values" do
    open_response.should be_valid
  end

  it 'has a self-generated storage key' do
    open_response.storage_key.should_not be_nil
  end
end
