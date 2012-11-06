
require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponse do
  before(:each) do
    @orclass = Embeddable::OpenResponse
  end

  it "should create a new instance with default values" do
    open_response = Embeddable::OpenResponse.create
    open_response.save 
    open_response.should be_valid
  end
end
