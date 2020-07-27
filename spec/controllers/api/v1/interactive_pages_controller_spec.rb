require 'spec_helper'

describe Api::V1::InteractivePagesController do
  let (:author) { FactoryGirl.create(:author) }
  let(:project) { FactoryGirl.create(:project) }
  let(:theme) { FactoryGirl.create(:theme) }
  let (:publication_status) { "public" }
  let (:act) { FactoryGirl.create(:public_activity, project: project, theme: theme, publication_status: publication_status, user: author ) }
  let (:page) { FactoryGirl.create(:page, :lightweight_activity => act) }
  let (:library_interactive1) { FactoryGirl.create(:library_interactive,
                                                   :name => 'Test Library Interactive 1',
                                                   :base_url => 'http://foo.com/',
                                                   :thumbnail_url => nil
                                                  ) }
  let (:library_interactive2) { FactoryGirl.create(:library_interactive,
                                                   :name => 'Test Library Interactive 2',
                                                   :base_url => 'http://bar.com/',
                                                   :thumbnail_url => 'http://thumbnail.url',
                                                   :no_snapshots => true
                                                  ) }
  let (:interactive1) { FactoryGirl.create(:mw_interactive) }
  let (:interactive2) { FactoryGirl.create(:mw_interactive, :no_snapshots => true) }
  let (:interactive3) { FactoryGirl.create(:mw_interactive) }
  let (:interactive4) { FactoryGirl.create(:managed_interactive, :library_interactive => library_interactive1, :url_fragment => "test1") }
  let (:interactive5) { FactoryGirl.create(:managed_interactive, :library_interactive => library_interactive2, :url_fragment => "test2") }

  def add_interactive_to_section(page, interactive, section)
    page.add_embeddable(interactive, nil, section)
    interactive.reload
  end

  describe "#get_interactive_list" do

    describe "on an unknown page" do
      it "returns an error" do
        xhr :get, "get_interactive_list", {id: 0}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: false,
          message: "Could not find interactive page #0"
        }.to_json)
      end
    end

    describe "using an invalid scope" do
      it "returns an error" do
        xhr :get, "get_interactive_list", {id: page.id, scope: "flarm"}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: false,
          message: "Invalid scope parameter: flarm"
        }.to_json)
      end
    end

    describe "in a private activity" do
      let (:publication_status) { "private" }

      it "returns an error" do
        xhr :get, "get_interactive_list", {id: page.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: false,
          message: "You are not authorized to get the interactive list from the requested page"
        }.to_json)
      end
    end

    describe "on a page with no interactives" do
      it "returns an empty list" do
        xhr :get, "get_interactive_list", {id: page.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true,
          interactives: []
        }.to_json)
      end
    end

    describe "on a page with interactives" do
      before :each do
        add_interactive_to_section(page, interactive1, InteractivePage::INTERACTIVE_BOX)
        add_interactive_to_section(page, interactive2, InteractivePage::HEADER_BLOCK)
        add_interactive_to_section(page, interactive3, nil) # nil is assessment block
        add_interactive_to_section(page, interactive4, InteractivePage::INTERACTIVE_BOX)
        add_interactive_to_section(page, interactive5, InteractivePage::HEADER_BLOCK)
        page.save!(validate: true)
        page.reload
      end

      it "returns the list of all interactives when no supportsSnapshots param is present" do
        xhr :get, "get_interactive_list", {id: page.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true,
          interactives: [
            {id: interactive3.page_item.id, pageId: page.id, name: interactive3.name, section: "assessment_block", url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive2.page_item.id, pageId: page.id, name: interactive2.name, section: InteractivePage::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.page_item.id, pageId: page.id, name: interactive5.name, section: InteractivePage::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false},
            {id: interactive1.page_item.id, pageId: page.id, name: interactive1.name, section: InteractivePage::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.page_item.id, pageId: page.id, name: interactive4.name, section: InteractivePage::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true}
          ]
        }.to_json)
      end

      it "returns the correct list of all interactives when supportsSnapshots param is true" do
        xhr :get, "get_interactive_list", {id: page.id, supportsSnapshots: "true"}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true,
          interactives: [
            {id: interactive3.page_item.id, pageId: page.id, name: interactive3.name, section: "assessment_block", url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive1.page_item.id, pageId: page.id, name: interactive1.name, section: InteractivePage::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.page_item.id, pageId: page.id, name: interactive4.name, section: InteractivePage::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true}
          ]
        }.to_json)
      end

      it "returns the correct list of all interactives when supportsSnapshots param is false" do
        xhr :get, "get_interactive_list", {id: page.id, supportsSnapshots: "false"}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true,
          interactives: [
            {id: interactive2.page_item.id, pageId: page.id, name: interactive2.name, section: InteractivePage::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.page_item.id, pageId: page.id, name: interactive5.name, section: InteractivePage::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false}
          ]
        }.to_json)
      end
    end
  end

  describe "#set_linked_interactives" do

    describe "on an unknown page" do
      it "returns an error" do
        xhr :post, "set_linked_interactives", {id: 0}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: false,
          message: "Could not find interactive page #0"
        }.to_json)
      end
    end

    describe "in a private activity" do
      let (:publication_status) { "private" }

      it "returns an error" do
        xhr :post, "set_linked_interactives", {id: page.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: false,
          message: "You are not authorized to set linked interactives for the requested page"
        }.to_json)
      end
    end

    describe "on a page with interactives" do
      before :each do
        # need to be an author to create linked interactives
        sign_in author

        add_interactive_to_section(page, interactive1, InteractivePage::INTERACTIVE_BOX)
        add_interactive_to_section(page, interactive2, InteractivePage::HEADER_BLOCK)
        add_interactive_to_section(page, interactive3, nil) # nil is assessment block
        add_interactive_to_section(page, interactive4, InteractivePage::INTERACTIVE_BOX)
        add_interactive_to_section(page, interactive5, InteractivePage::HEADER_BLOCK)
        page.save!(validate: true)
        page.reload
      end

      describe "returns an error when there is no source param" do
        it "returns an error" do
          xhr :post, "set_linked_interactives", {id: page.id}
          expect(response.status).to eq(200)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eql({
            success: false,
            message: "Missing sourceId parameter in request"
          }.to_json)
        end
      end

      describe "returns an error when there is an invalid source param" do
        it "returns an error" do
          xhr :post, "set_linked_interactives", {
            id: page.id,
            sourceId: 1000000000
          }
          expect(response.status).to eq(200)
          expect(response.content_type).to eq("application/json")
          expect(response.body).to eql({
            success: false,
            message: "Invalid sourceId parameter in request"
          }.to_json)
        end
      end

      it "allows a 1:1 link" do
        xhr :post, "set_linked_interactives", {
          id: page.id,
          sourceId: interactive1.page_item.id,
          linkedInteractives: {
            "#{interactive2.page_item.id}": {label: "two"}
          },
          linkedState: interactive3.page_item.id
        }
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true
        }.to_json)
      end

      it "allows a 1:N link" do
        xhr :post, "set_linked_interactives", {
          id: page.id,
          sourceId: interactive1.page_item.id,
          linkedInteractives: {
            "#{interactive2.page_item.id}": {label: "two"},
            "#{interactive3.page_item.id}": {label: "three"}
          },
          linkedState: interactive3.page_item.id
        }
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to eql({
          success: true
        }.to_json)
      end
    end
  end

end
