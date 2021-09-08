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
            {id: interactive2.interactive_item_id, pageId: page.id, name: interactive2.name, section: Section::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.interactive_item_id, pageId: page.id, name: interactive5.name, section: Section::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false},
            {id: interactive1.interactive_item_id, pageId: page.id, name: interactive1.name, section: Section::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.interactive_item_id, pageId: page.id, name: interactive4.name, section: Section::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive3.interactive_item_id, pageId: page.id, name: interactive3.name, section: Section::DEFAULT_SECTION_TITLE, url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true}
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
            {id: interactive1.interactive_item_id, pageId: page.id, name: interactive1.name, section: Section::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.interactive_item_id, pageId: page.id, name: interactive4.name, section: Section::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive3.interactive_item_id, pageId: page.id, name: interactive3.name, section: Section::DEFAULT_SECTION_TITLE, url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true}
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
            {id: interactive2.interactive_item_id, pageId: page.id, name: interactive2.name, section: InteractivePage::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.interactive_item_id, pageId: page.id, name: interactive5.name, section: InteractivePage::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false}
          ]
        }.to_json)
      end
    end
  end

  describe "#create_page_item" do
    let(:section) { FactoryGirl.create(:section, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }
    let(:library_interactive) { FactoryGirl.create(:library_interactive) }

    before :each do
      sign_in author
    end

    describe "fails" do
      it "without a page_item parameter" do
        xhr :post, "create_page_item", {id: page.id}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item parameter"
      end

      it "without a section_id parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {}}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[section_id] parameter"
      end

      it "with an invalid section_id parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {section_id: 0}}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Invalid page_item[section_id] parameter"
      end

      it "fails with a missing embeddable parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {
          section_id: section.id,
          position: 1,
          section_position: 1,
          column: 1
        }}
        expect(response.body).to include "Missing page_item[embeddable] parameter"
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[embeddable] parameter"
      end

      it "fails with an invalid embeddable parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {
          section_id: section.id,
          embeddable: "MwInteractive_1",
          position: 1,
          section_position: 1,
          column: 1
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Only library interactive embeddables are currently supported"
      end

      it "fails with an invalid library interactive parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {
          section_id: section.id,
          embeddable: "LibraryInteractive_0",
          position: 1,
          section_position: 1,
          column: 1
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Invalid page_item[embeddable] parameter"
      end
    end

    it "succeeds with valid parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: library_interactive.serializeable_id,
        position: 1,
        section_position: 1,
        column: 1
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end
end
