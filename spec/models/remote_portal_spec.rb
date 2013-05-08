require 'spec_helper'

describe RemotePortal do
  let(:params) do
    { :domain => "concord.org",
      :externalId => "23",
      :returnUrl => "http://concord.org/foo"
    }
  end

  describe "new" do
    it "should initialize properties" do
      portal = RemotePortal.new(params)
      portal.domain.should == params[:domain]
      portal.remote_id.should == params[:externalId]
      portal.remote_endpoint.should == params[:returnUrl]
    end

    it "should be valid with valid params" do
      RemotePortal.new(params).should be_valid
    end

  end
end