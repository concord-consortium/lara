require 'spec_helper'

describe ReportService::ResourceSender do
  let(:host)      { "app.lara.docker" }
  let(:id)        { "resource-id"}

  let(:resource) { FactoryGirl.create(:activity_with_page_and_or) }
  let(:sender)   { ReportService::ResourceSender.new(resource, host) }

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
        required_fields = ["version", "created", "source_key"]
        expect(json).to include(*required_fields)
      end

      it "The source key should contain host name info" do
        expect(json['source_key']).to match('app')
        expect(json['source_key']).to match('lara')
        expect(json['source_key']).to match('docker')
        expect(json['id']).to match('activity')
        expect(json['id']).to match("#{resource.id}")
      end

      it "Should have a children[] array" do
        expect(json['children']).not_to be_nil
      end
    end
  end

end
