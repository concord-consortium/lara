require 'spec_helper'

describe Api::V1::ImportController do
  let (:user) { FactoryGirl.create(:author) }
  let (:valid_activity_import_json) { JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json'), symbolize_keys: true) }
  let (:invalid_activity_import_json) { JSON.parse(File.read(Rails.root + 'spec/import_examples/invalid_lightweight_activity_import.json'), symbolize_keys: true) }

  describe "when user is logged in and allowed to import activity" do
    before(:each) do
      sign_in user
    end

    it "returns 200 and activity URL" do
      raw_post(:import, {}, {import: valid_activity_import_json}.to_json)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eql({
        success: true,
        url: activity_url(LightweightActivity.last)
      }.to_json)
    end

    describe "when import fails for some reason" do
      it "returns 500" do
        raw_post(:import, {}, {import: invalid_activity_import_json}.to_json)
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  describe "when user is not allowed to import activity" do
    it "returns 403" do
      raw_post(:import, {}, {import: valid_activity_import_json}.to_json)
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end
  end
end

def raw_post(action, params, body)
  @request.env['RAW_POST_DATA'] = body
  response = post(action, params)
  @request.env.delete('RAW_POST_DATA')
  response
end