require 'spec_helper'

describe Publishable do
  subject(:instance) do
  	# fake included for now
    allow(Publishable).to receive(:included) { "NO OP"}
    Class.new { include Publishable }.new
  end
  let (:authentication_token ) { "fake token" }
  let (:user) { double(authentication_token: "fake token") }
  let (:portal_url) { "fake portal url" }
  let (:portal) { double(strategy_name: 'fake strategy') }
  let (:self_url) { "fake self url"}
  describe "#portal_publish" do
  	it "should handle a portal url string argument" do
  	  is_expected.to receive(:update_attribute)
      expect(Concord::AuthPortal).to receive(:portal_for_url).with(portal_url).and_return( portal )
  	  is_expected.to receive(:portal_publish_with_token).with(authentication_token, portal, self_url)
      instance.portal_publish(user, portal_url, self_url )
  	end
  end
end