require 'spec_helper'

describe Api::V1::PageItemsController do
  let (:author) { FactoryBot.create(:author) }
  let (:project) { FactoryBot.create(:project) }
  let (:publication_status) { "public" }
  let (:act) { FactoryBot.create(:public_activity, project: project, publication_status: publication_status, user: author ) }
  let (:page) { FactoryBot.create(:page, lightweight_activity: act) }
  let (:library_interactive1) { FactoryBot.create(:library_interactive,
                                                   name: 'Test Library Interactive 1',
                                                   base_url: 'http://foo.com/',
                                                   thumbnail_url: nil
                                                  ) }
  let (:interactive1) { FactoryBot.create(:mw_interactive) }

  describe "#get_embeddable_metadata" do
    it "returns JSON for a page item's embeddable" do
      puts interactive1.inspect
      get "get_embeddable_metadata", params: {id: 1}, xhr: true
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end
  end

end
