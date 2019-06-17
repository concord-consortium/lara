require 'spec_helper'

describe ReportService::ResourceSender do
  let(:self_host)            { "app.lara.docker" }
  let(:report_service_url)   { "fake-report-service.foo" }
  let(:report_service_token) { "secret-token-ssh" }
  let(:id)        { "resource-id"}

  let(:resource) { FactoryGirl.create(:activity_with_page_and_or) }
  let(:sender)   { ReportService::ResourceSender.new(resource) }

  before(:each) do
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return(self_host)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return(report_service_url)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return(report_service_token)
  end

  describe "to_json" do
    it "should be a string with a length" do
      expect(sender.to_json().length).to be > 1
    end

    it "should parse" do
      expect { JSON.parse(sender.to_json()) }.not_to raise_error
    end

    describe "the encoded values" do
      let(:json) { JSON.parse(sender.to_json())}
      it "should have required resource key fields" do
        required_fields = ["version", "created", "tool_id"]
        expect(json).to include(*required_fields)
      end

      it "The source key should contain host name info" do
        expect(json['source_key']).to match('app')
        expect(json['source_key']).to match('lara')
        expect(json['source_key']).to match('docker')
        expect(json['tool_id']).to match('app')
        expect(json['tool_id']).to match('lara')
        expect(json['tool_id']).to match('docker')
        expect(json['id']).to match('activity')
        expect(json['id']).to match("#{resource.id}")
      end

      it "Should have a children[] array" do
        expect(json['children']).not_to be_nil
      end
    end

    describe "when the service is not configured"  do
      let(:report_service_token) { nil }
      it "should raise an excpeption" do
        expect {sender}.to raise_error(ReportService::NotConfigured)
      end
    end
  end

end
