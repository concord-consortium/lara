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
      expect(portal.domain).to eq(params[:domain])
      expect(portal.remote_id).to eq(params[:externalId])
      expect(portal.remote_endpoint).to eq(params[:returnUrl])
    end

    it "should be valid with valid params" do
      expect(RemotePortal.new(params)).to be_valid
    end

  end
end