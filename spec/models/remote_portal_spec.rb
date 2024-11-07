require 'spec_helper'

describe RemotePortal do
  let(:params) do
    { domain: "concord.org",
      externalId: "23",
      returnUrl: "https://concord.org/foo",
      platform_id: "platform",
      platform_user_id: "123",
      resource_link_id: "link_1",
      context_id: "context_1",
      class_info_url: "http://class.url"
    }
  end

  describe "new" do
    it "should initialize properties" do
      portal = RemotePortal.new(params)
      expect(portal.domain).to eq(params[:domain])
      expect(portal.remote_id).to eq(params[:externalId])
      expect(portal.remote_endpoint).to eq(params[:returnUrl])
      expect(portal.platform_info).to eq({
        platform_id: "platform",
        platform_user_id: "123",
        resource_link_id: "link_1",
        context_id: "context_1",
        class_info_url: "http://class.url"
      })
    end

    it "should be valid with valid params" do
      expect(RemotePortal.new(params)).to be_valid
    end

  end
end
