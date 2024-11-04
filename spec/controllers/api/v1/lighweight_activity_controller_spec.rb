require 'spec_helper'

describe Api::V1::LightweightActivitiesController do
  let (:admin) { FactoryGirl.create(:admin) }
  let (:author1) { FactoryGirl.create(:author) }
  let (:author2) { FactoryGirl.create(:author) }
  let (:activity) { FactoryGirl.create(:activity, user: author1) }

  describe "#show" do
    it 'recognizes and generates #show' do
      expect({get: "api/v1/activities/1.json"}).to route_to(
        controller: 'api/v1/lightweight_activities',
        action: 'show',
        id: "1",
        format: "json"
      )
    end

    it "when user is anonymous, shows an activity's json" do

      get :show, params: { id: activity.id, format: :json }
      expect(response.status).to eq(200)
      # json_response = JSON.parse(response.body)
      # expect(json_response["token"]).to eq('fake-token')
    end
  end

  describe "#report_structure" do
    it 'recognizes and generates #report_structure' do
      expect({get: "api/v1/activities/1/report_structure.json"}).to route_to(
        controller: 'api/v1/lightweight_activities',
        action: 'report_structure',
        id: "1",
        format: "json"
      )
    end

    it "when user is anonymous, shows an the json sent to the report structure" do

      get :report_structure, params: { id: activity.id, format: :json }
      expect(response.status).to eq(200)
      # json_response = JSON.parse(response.body)
      # expect(json_response["token"]).to eq('fake-token')
    end
  end

  describe "#destroy" do
    def expect_success_for(user)
      if user
        sign_in user
      end
      delete "destroy", params: { id: activity.id }, xhr: true
      expect(LightweightActivity.exists?(activity.id)).to eq(false)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eql({
        success: true
      }.to_json)
    end

    def expect_fail_for(user)
      if user
        sign_in user
      end
      delete "destroy", params: { id: activity.id }, xhr: true
      expect(LightweightActivity.exists?(activity.id)).to eq(true)
      expect(response.status).to eq(403)
      expect(response.content_type).to eq("application/json")
    end

    it "when user is an admin, destroys an activity" do
      expect_success_for(admin)
    end

    it "when user is an author, destroys an activity" do
      expect_success_for(author1)
    end

    it "when user is not an author, does not destroy an activity" do
      expect_fail_for(author2)
    end

    it "when user is anonymous, does not destroy an activity" do
      expect_fail_for(nil)
    end
  end
end
