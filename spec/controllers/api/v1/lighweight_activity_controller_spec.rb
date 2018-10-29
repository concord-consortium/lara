require 'spec_helper'

describe Api::V1::LightweightActivitiesController do
  let (:admin) { FactoryGirl.create(:admin) }
  let (:author1) { FactoryGirl.create(:author) }
  let (:author2) { FactoryGirl.create(:author) }
  let (:activity) { FactoryGirl.create(:activity, user: author1) }

  describe "#destroy" do
    def expect_success_for(user)
      if user
        sign_in user
      end
      xhr :delete, "destroy", id: activity.id
      expect(LightweightActivity.exists?(activity)).to eq(false)
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
      xhr :delete, "destroy", id: activity.id
      expect(LightweightActivity.exists?(activity)).to eq(true)
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
