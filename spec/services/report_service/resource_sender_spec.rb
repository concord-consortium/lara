require 'spec_helper'

describe ReportService::ResourceSender do
  let(:self_host)            { "app.lara.docker" }
  let(:report_service_url)   { "fake-report-service.foo" }
  let(:report_service_token) { "secret-token-ssh" }
  let(:id)                   { "resource-id"}
  let(:activity_player_url)  { "http://ap.url/"}

  let(:resource) { FactoryGirl.create(:activity_with_page_and_or) }
  let(:sender)   { ReportService::ResourceSender.new(resource) }

  before(:each) do
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return(self_host)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return(report_service_url)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return(report_service_token)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return(nil)
    allow(ENV).to receive(:[]).with("ACTIVITY_PLAYER_URL").and_return(activity_player_url)
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
        expect(json['source_key']).to match('app.lara.docker')
        expect(json['tool_id']).to match('app.lara.docker')
        expect(json['id']).to match('activity')
        expect(json['id']).to match("#{resource.id}")
      end

      it "Should have a children[] array" do
        expect(json['children']).not_to be_nil
      end

      context "when a developer overrides the tool id" do
        before(:each) do
          allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return("http://local.dev.test")
        end

        it "The tool id should match what the developer set" do
          expect(json['tool_id']).to match('http://local.dev.test')
        end

        it "The source key should contain host name info from the tool_id" do
          expect(json['source_key']).to match('local.dev.test')
          # should check the resourceId continues to match the self_url
        end

        it "The resourceUrl should still start with the self_url" do
          expect(json['url']).to start_with(self_host)
        end
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
