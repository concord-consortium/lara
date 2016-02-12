require 'spec_helper'

describe PortalSender::Protocol do
  let(:endpoint)            { "http://localhost/dataservice/external_activity_data/6" }
  let(:auth_stubs)          { {} }
  let(:protocol)            { PortalSender::Protocol.new       }
  let(:mock_auth_provider)  { double(auth_stubs)               }
  let(:post_results)        { {}                               }
  let(:answer_data)         { double({portal_hash: {one: 1}, updated_at: Time.now }) }
  let(:sad_result)   { double({ success?: false, code: 500, message: 'failure'})}
  let(:happy_result) { double({ success?: true, code: 200, message: 'yipee'})}

  before(:each) do
    allow(Run).to receive(:auth_provider).and_return mock_auth_provider
    allow(HTTParty).to receive(:post).and_return post_results
    allow(Concord::AuthPortal).to receive(:auth_token_for_url).and_return "xyzzy"
  end


  describe "add-hoc routing maddness" do

  end

  describe "when the portal supports the latest version of the protocol" do
    let(:post_results) { happy_result }
    it "should not be using the most rescent protocol version after sending" do
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.first
    end
  end

  describe "when the portal is using an older version of the protocol" do
    let(:post_results) { sad_result }
    it "should not be using the most rescent protocol version after sending" do
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.last
    end
  end

  describe "retrying the first version again after some time passes" do

    let(:post_results) { sad_result }
    it "should not be using the most rescent protocol version after sending" do
      # Using old version
      allow(HTTParty).to receive(:post).and_return sad_result
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.last

      # Checkin again in the future:
      Timecop.travel(3.hours.from_now)
      allow(HTTParty).to receive(:post).and_return happy_result
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.first
    end
  end

  describe "#instance and caching protocols for servers" do
    let(:endpoint_a)  { "http://localhost/dataservice/external_activity_data/6"    }
    let(:endpoint_b)  { "http://localhost/dataservice/external_activity_data/7"    }
    let(:endpoint_c)  { "http://localhost:80/dataservice/external_activity_data/8" }
    let(:endpoint_d)  { "http://127.0.0.1/dataservice/external_activity_data/6"    }
    let(:endpoint_e)  { "http://google.com/dataservice/external_activity_data/6"    }

    describe "when multiple endpoints use the same serve" do
      it "should return the same protocol" do
        expect(PortalSender::Protocol.instance(endpoint_a)).to eq PortalSender::Protocol.instance(endpoint_b)
        expect(PortalSender::Protocol.instance(endpoint_b)).to eq PortalSender::Protocol.instance(endpoint_c)
      end
    end

    describe "when endpoints use different servers" do
      it "should use a new protocol for each one" do
        expect(PortalSender::Protocol.instance(endpoint_a)).not_to eq PortalSender::Protocol.instance(endpoint_d)
        expect(PortalSender::Protocol.instance(endpoint_d)).not_to eq PortalSender::Protocol.instance(endpoint_e)
      end
    end
  end

end