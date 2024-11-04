require 'spec_helper'

describe Api::V1::PageItemsController do
  let (:author) { FactoryGirl.create(:author) }
  let (:project) { FactoryGirl.create(:project) }
  let (:publication_status) { "public" }
  let (:act) { FactoryGirl.create(:public_activity, project: project, publication_status: publication_status, user: author ) }
  let (:page) { FactoryGirl.create(:page, lightweight_activity: act) }
  let (:library_interactive1) { FactoryGirl.create(:library_interactive,
                                                   name: 'Test Library Interactive 1',
                                                   base_url: 'http://foo.com/',
                                                   thumbnail_url: nil
                                                  ) }
  let (:interactive1) { FactoryGirl.create(:mw_interactive) }

  describe "#get_embeddable_metadata" do
    it "returns JSON for a page item's embeddable" do
      puts interactive1.inspect
      get, "get_embeddable_metadata", {id: 1}, xhr: true
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

end
