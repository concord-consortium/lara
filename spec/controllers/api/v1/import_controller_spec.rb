require 'spec_helper'

describe Api::V1::ImportController do
  let (:user) { FactoryGirl.create(:author) }
  let (:valid_activity_import_json) { JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json'), symbolize_keys: true) }

  describe "when user is logged in and allowed to import activity" do
    before(:each) do
      sign_in user
    end

    it "returns 200 and activity URL" do
      xhr :post, "import", {import: valid_activity_import_json}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eql({
        success: true,
        url: activity_url(LightweightActivity.last)
      }.to_json)
    end
  end

  describe "when user is not allowed to import activity" do
    it "returns 403" do
      xhr :post, "import", {import: valid_activity_import_json}
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end
  end
end
