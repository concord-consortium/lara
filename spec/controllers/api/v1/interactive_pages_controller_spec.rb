require 'spec_helper'

describe Api::V1::InteractivePagesController do
  let (:admin) { FactoryGirl.create(:admin) }
  let (:author) { FactoryGirl.create(:author) }
  let (:project) { FactoryGirl.create(:project) }
  let (:publication_status) { "public" }
  let (:act) { FactoryGirl.create(:public_activity, project: project, publication_status: publication_status, user: author ) }
  let (:page) { FactoryGirl.create(:page, :lightweight_activity => act) }
  let (:library_interactive1) { FactoryGirl.create(:library_interactive,
                                                   :name => 'Test Library Interactive 1',
                                                   :base_url => 'http://foo.com/',
                                                   :thumbnail_url => nil,
                                                   :official => true
                                                  ) }
  let (:library_interactive2) { FactoryGirl.create(:library_interactive,
                                                   :name => 'Test Library Interactive 2',
                                                   :base_url => 'http://bar.com/',
                                                   :thumbnail_url => 'http://thumbnail.url',
                                                   :no_snapshots => true,
                                                   :official => false
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
            {id: interactive2.interactive_item_id, embeddableId: interactive2.id, pageId: page.id, name: interactive2.name, section: Section::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.interactive_item_id, embeddableId: interactive5.id, pageId: page.id, name: interactive5.name, section: Section::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false},
            {id: interactive1.interactive_item_id, embeddableId: interactive1.id, pageId: page.id, name: interactive1.name, section: Section::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.interactive_item_id, embeddableId: interactive4.id, pageId: page.id, name: interactive4.name, section: Section::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive3.interactive_item_id, embeddableId: interactive3.id, pageId: page.id, name: interactive3.name, section: Section::DEFAULT_SECTION_TITLE, url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true}
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
            {id: interactive1.interactive_item_id, embeddableId: interactive1.id, pageId: page.id, name: interactive1.name, section: Section::INTERACTIVE_BOX, url: interactive1.url, thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive4.interactive_item_id, embeddableId: interactive4.id, pageId: page.id, name: interactive4.name, section: Section::INTERACTIVE_BOX, url: "http://foo.com/test1", thumbnailUrl: nil, supportsSnapshots: true},
            {id: interactive3.interactive_item_id, embeddableId: interactive3.id, pageId: page.id, name: interactive3.name, section: Section::DEFAULT_SECTION_TITLE, url: interactive3.url, thumbnailUrl: nil, supportsSnapshots: true}
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
            {id: interactive2.interactive_item_id, embeddableId: interactive2.id, pageId: page.id, name: interactive2.name, section: InteractivePage::HEADER_BLOCK, url: interactive2.url, thumbnailUrl: nil, supportsSnapshots: false},
            {id: interactive5.interactive_item_id, embeddableId: interactive5.id, pageId: page.id, name: interactive5.name, section: InteractivePage::HEADER_BLOCK, url: "http://bar.com/test2", thumbnailUrl: "http://thumbnail.url", supportsSnapshots: false}
          ]
        }.to_json)
      end
    end
  end

  describe "#create_page_item" do
    let(:section) { FactoryGirl.create(:section, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }

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
          column: PageItem::COLUMN_PRIMARY
        }}
        expect(response.body).to include "Missing page_item[embeddable] parameter"
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[embeddable] parameter"
      end

      it "fails with an invalid type parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {
          section_id: section.id,
          embeddable: "Invalid_1",
          position: 1,
          section_position: 1,
          column: PageItem::COLUMN_PRIMARY
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Only library interactive embeddables, iFrame interactives, and text blocks are currently supported"
      end

      it "fails with an invalid library interactive parameter" do
        xhr :post, "create_page_item", {id: page.id, page_item: {
          section_id: section.id,
          embeddable: "LibraryInteractive_0",
          position: 1,
          section_position: 1,
          column: PageItem::COLUMN_PRIMARY
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Invalid page_item[embeddable] parameter"
      end
    end

    it "succeeds with valid LibraryInteractive parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: library_interactive1.serializeable_id,
        position: 1,
        section_position: 1,
        column: PageItem::COLUMN_PRIMARY
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end

    it "succeeds with valid MWInteractive parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: "MwInteractive",
        position: 1,
        section_position: 1,
        column: PageItem::COLUMN_PRIMARY
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end

    it "succeeds with valid windowshade plugin parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: "Plugin_1::windowShade",
        position: 1,
        section_position: 1,
        column: PageItem::COLUMN_PRIMARY
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end

    it "succeeds with valid question wrapper plugin parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: "Plugin_1::questionWrapper",
        position: 1,
        section_position: 1,
        column: PageItem::COLUMN_PRIMARY
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end

    it "succeeds with valid side tip plugin parameters" do
      xhr :post, "create_page_item", {id: page.id, page_item: {
        section_id: section.id,
        embeddable: "Plugin_1::sideTip",
        position: 1,
        section_position: 1,
        column: PageItem::COLUMN_PRIMARY
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "#get_library_interactives_list" do
    let (:managed_interactive1) { FactoryGirl.create(:managed_interactive,
      :library_interactive_id => library_interactive1.id
    )}

    it "returns a list of all library interactives including all properties for signed-in admins" do
      sign_in admin

      # make sure the mocks exist
      library_interactive1
      library_interactive2
      managed_interactive1

      expected_response_for_admin = {
        success: true,
        library_interactives: [
          {
            aspect_ratio_method: library_interactive1.aspect_ratio_method,
            authorable: library_interactive1.authorable,
            authoring_guidance: library_interactive1.authoring_guidance,
            base_url: library_interactive1.base_url,
            click_to_play: library_interactive1.click_to_play,
            click_to_play_prompt: library_interactive1.click_to_play_prompt,
            created_at: library_interactive1.created_at,
            customizable: library_interactive1.customizable,
            date_added: library_interactive1.created_at.to_i,
            description: library_interactive1.description,
            enable_learner_state: library_interactive1.enable_learner_state,
            export_hash: library_interactive1.export_hash,
            full_window: library_interactive1.full_window,
            has_report_url: library_interactive1.has_report_url,
            hide_question_number: library_interactive1.hide_question_number,
            id: library_interactive1.id,
            image_url: library_interactive1.image_url,
            name: library_interactive1.name,
            native_height: library_interactive1.native_height,
            native_width: library_interactive1.native_width,
            no_snapshots: library_interactive1.no_snapshots,
            official: library_interactive1.official,
            report_item_url: library_interactive1.report_item_url,
            serializeable_id: library_interactive1.serializeable_id,
            show_delete_data_button: library_interactive1.show_delete_data_button,
            thumbnail_url: library_interactive1.thumbnail_url,
            updated_at: library_interactive1.updated_at,
            use_count: 1
          },
          {
            aspect_ratio_method: library_interactive2.aspect_ratio_method,
            authorable: library_interactive2.authorable,
            authoring_guidance: library_interactive2.authoring_guidance,
            base_url: library_interactive2.base_url,
            click_to_play: library_interactive2.click_to_play,
            click_to_play_prompt: library_interactive2.click_to_play_prompt,
            created_at: library_interactive2.created_at,
            customizable: library_interactive2.customizable,
            date_added: library_interactive2.created_at.to_i,
            description: library_interactive2.description,
            enable_learner_state: library_interactive2.enable_learner_state,
            export_hash: library_interactive2.export_hash,
            full_window: library_interactive2.full_window,
            has_report_url: library_interactive2.has_report_url,
            hide_question_number: library_interactive2.hide_question_number,
            id: library_interactive2.id,
            image_url: library_interactive2.image_url,
            name: library_interactive2.name,
            native_height: library_interactive2.native_height,
            native_width: library_interactive2.native_width,
            no_snapshots: library_interactive2.no_snapshots,
            official: library_interactive2.official,
            report_item_url: library_interactive2.report_item_url,
            serializeable_id: library_interactive2.serializeable_id,
            show_delete_data_button: library_interactive2.show_delete_data_button,
            thumbnail_url: library_interactive2.thumbnail_url,
            updated_at: library_interactive2.updated_at,
            use_count: 0
          }
        ],
        # TODO: Add some page-level plugins to test...
        plugins: []
      }.to_json

      xhr :get, "get_library_interactives_list"
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      actual_response = JSON.parse(response.body)
      expected_response = JSON.parse(expected_response_for_admin)
      actual_response["library_interactives"].each_with_index do |interactive, index|
        expected = expected_response["library_interactives"][index]
        expect(interactive).to eq(expected)
      end
    end

    it "returns a list of all library interactives including all properties for non admins" do
      sign_in author

      # make sure the mocks exist
      library_interactive1
      library_interactive2
      managed_interactive1

      expected_response_for_non_admin = {
        success: true,
        library_interactives: [
          {
            aspect_ratio_method: library_interactive1.aspect_ratio_method,
            authorable: library_interactive1.authorable,
            authoring_guidance: library_interactive1.authoring_guidance,
            base_url: library_interactive1.base_url,
            click_to_play: library_interactive1.click_to_play,
            click_to_play_prompt: library_interactive1.click_to_play_prompt,
            created_at: library_interactive1.created_at,
            customizable: library_interactive1.customizable,
            date_added: library_interactive1.created_at.to_i,
            description: library_interactive1.description,
            enable_learner_state: library_interactive1.enable_learner_state,
            export_hash: library_interactive1.export_hash,
            full_window: library_interactive1.full_window,
            has_report_url: library_interactive1.has_report_url,
            hide_question_number: library_interactive1.hide_question_number,
            id: library_interactive1.id,
            image_url: library_interactive1.image_url,
            name: library_interactive1.name,
            native_height: library_interactive1.native_height,
            native_width: library_interactive1.native_width,
            no_snapshots: library_interactive1.no_snapshots,
            official: library_interactive1.official,
            report_item_url: library_interactive1.report_item_url,
            serializeable_id: library_interactive1.serializeable_id,
            show_delete_data_button: library_interactive1.show_delete_data_button,
            thumbnail_url: library_interactive1.thumbnail_url,
            updated_at: library_interactive1.updated_at,
            use_count: 1
          },
          {
            aspect_ratio_method: library_interactive2.aspect_ratio_method,
            authorable: library_interactive2.authorable,
            authoring_guidance: library_interactive2.authoring_guidance,
            base_url: library_interactive2.base_url,
            click_to_play: library_interactive2.click_to_play,
            click_to_play_prompt: library_interactive2.click_to_play_prompt,
            created_at: library_interactive2.created_at,
            customizable: library_interactive2.customizable,
            date_added: library_interactive2.created_at.to_i,
            description: library_interactive2.description,
            enable_learner_state: library_interactive2.enable_learner_state,
            export_hash: library_interactive2.export_hash,
            full_window: library_interactive2.full_window,
            has_report_url: library_interactive2.has_report_url,
            hide_question_number: library_interactive2.hide_question_number,
            id: library_interactive2.id,
            image_url: library_interactive2.image_url,
            name: library_interactive2.name,
            native_height: library_interactive2.native_height,
            native_width: library_interactive2.native_width,
            no_snapshots: library_interactive2.no_snapshots,
            official: library_interactive2.official,
            report_item_url: library_interactive2.report_item_url,
            serializeable_id: library_interactive2.serializeable_id,
            show_delete_data_button: library_interactive2.show_delete_data_button,
            thumbnail_url: library_interactive2.thumbnail_url,
            updated_at: library_interactive2.updated_at,
            use_count: 0
          }
        ],
        # TODO: Add some page-level plugins to test...
        plugins: []
      }.to_json

      xhr :get, "get_library_interactives_list"
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      actual_response = JSON.parse(response.body)
      expected_response = JSON.parse(expected_response_for_non_admin)
      actual_response["library_interactives"].each_with_index do |interactive, index|
        expected = expected_response["library_interactives"][index]
        expect(interactive).to eq(expected)
      end
    end
  end

  describe "#update_page_item" do
    let(:section) { FactoryGirl.create(:section, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }
    let(:data) { { name: "Text Block 1", content: "Some text.", is_callout: false, is_half_width: true, is_hidden: false } }
    let(:new_data) { { name: "Text Block 1v2", content: "I changed my mind.", is_callout: true, is_half_width: false, is_hidden: true } }
    let(:embeddable) { FactoryGirl.create(:xhtml, data)}
    let(:embeddable_type) { "Embeddable::Xhtml" }
    let(:page_item) { FactoryGirl.create(:page_item, { section: section, column: PageItem::COLUMN_PRIMARY, position: 1, embeddable: embeddable })}

    before :each do
      sign_in author
    end

    describe "fails" do
      it "without a page_item parameter" do
        xhr :post, "update_page_item", {id: page.id}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item parameter"
      end

      it "without an id parameter" do
        xhr :post, "update_page_item", {id: page.id, page_item: {}}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[id] parameter"
      end

      it "without a column parameter" do
        xhr :post, "update_page_item", {id: page.id, page_item: {
          id: page_item.id
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[column] parameter"
      end

      it "without a position parameter" do
        xhr :post, "update_page_item", {id: page.id, page_item: {
          id: page_item.id,
          column: page_item.column
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[position] parameter"
      end

      it "without a data parameter" do
        xhr :post, "update_page_item", {id: page.id, page_item: {
          id: page_item.id,
          column: page_item.column,
          position: page_item.position
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[data] parameter"
      end

      it "without a type parameter" do
        xhr :post, "update_page_item", {id: page.id, page_item: {
          id: page_item.id,
          column: page_item.column,
          position: page_item.position,
          data: new_data
        }}
        expect(response.status).to eq(500)
        expect(response.content_type).to eq("application/json")
        expect(response.body).to include "Missing page_item[type] parameter"
      end
    end

    it "succeeds with valid parameters" do
      xhr :post, "update_page_item", {id: page.id, page_item: {
        id: page_item.id,
        column: page_item.column,
        position: page_item.position,
        data: new_data,
        type: embeddable_type
      }}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eql(
        {
          id: page_item.id.to_s,
          column: page_item.column,
          position: page_item.position,
          type: embeddable_type,
          data: {
            name: new_data[:name],
            content: new_data[:content],
            is_hidden: new_data[:is_hidden],
            is_half_width: new_data[:is_half_width],
            is_callout: new_data[:is_callout]
          },
          authoring_api_urls: {}
        }.to_json
      )
    end
  end

  describe "#get_pages" do
    let(:page_count) { 5 }
    let(:pages)      { FactoryGirl.create_list(:page, page_count, lightweight_activity: act)}

    describe "succeeds" do
      it "with an activity_id and pages" do
        pages
        act.reload
        xhr :get, "get_pages", {activity_id: act.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        pages = JSON.parse(response.body)
        expect(pages.length).to eql(page_count)
      end
    end

    describe "fails" do
      it "with invalid activity id" do
        xhr :get, "get_pages", {activity_id: 234232}
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#create_page" do
    describe "succeeds" do
      before :each do
        sign_in author
      end

      it "when the activity author is creating the page" do
        before_count = act.pages.length
        after_count = act.pages.length + 1

        xhr :post, "create_page", {activity_id: act.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        pages = JSON.parse(response.body)
        expect(pages.length).to eql(after_count)
      end
    end

    describe "fails" do
      it "when the current user is not the activity author" do
        xhr :post, "create_page", {activity_id: act.id}
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#delete_page" do
    let(:page_count) { 5 }
    let(:pages)      { FactoryGirl.create_list(:page, page_count, lightweight_activity: act)}

    describe "succeeds" do
      before :each do
        sign_in author
      end

      it "when the activity author is deleting" do
        page  = pages.first
        act.reload
        before_count = act.pages.length
        after_count = act.pages.length - 1

        xhr :post, "delete_page", {id: page.id}
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(JSON.parse(response.body)).to eq({"success"=> true})
        expect(act.reload.pages.length).to eql(after_count)
      end
    end

    describe "fails" do
      before :each do
        sign_out author
      end
      it "when the current user is not the activity author" do
        page  = pages.first
        act.reload
        before_count = act.pages.length
        after_count = before_count

        xhr :post, "delete_page", {id: page.id}
        expect(response.status).to eq(403)
        expect(act.pages.length).to eq(after_count)
      end
    end
  end

  describe "#update_section" do
    let(:section) { FactoryGirl.create(:section, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }
    let(:items)   do
      [
        FactoryGirl.create(:page_item, { section: section, position: 1, column: PageItem::COLUMN_PRIMARY }),
        FactoryGirl.create(:page_item, { section: section, position: 2, column: PageItem::COLUMN_PRIMARY }),
        FactoryGirl.create(:page_item, { section: section, position: 3, column: PageItem::COLUMN_PRIMARY })
      ]
    end

    before :each do
      sign_in author
    end

    describe 'reordering items' do
      it 'before we run the update the items position should be in order' do
        section.page_items.each_with_index do |pi, index|
          expect(pi.position).to eql(index)
        end
      end

      describe 'success' do
        it 'after the reordering, the items positions are reversed' do
          new_items = items.map do |i|
            {
              id: i.id,
              position: 4 - i.position,
              column: i.column
            }
          end
          old_id_order = section.page_items.map(& :id)
          update_request = { id: page.id, section: { id: section.id, items: new_items } }
          xhr :post, 'update_section', update_request
          expect(response.status).to eq(200)
          section.reload
          new_id_order = section.page_items.map(& :id)
          expect(new_id_order).to eql(old_id_order.reverse)
        end

        it 'will add new items' do
          extra_item = FactoryGirl.create(:page_item, { column: PageItem::COLUMN_PRIMARY })
          items << extra_item
          expect(section.page_items.length).to eql(3)
          update_request = { id: page.id, section: { id: section.id, items: items.map(&:attributes) } }
          xhr :post, 'update_section', update_request
          expect(response.status).to eq(200)
          section.reload
          expect(section.page_items.length).to eql(4)
        end

        it 'will delete missing items' do
          new_items = items[0, 2].map { |i| { id: i.id, column: i.column } }
          expect(section.page_items.length).to eql(3)
          update_request = { id: page.id, section: { id: section.id, items: new_items } }
          xhr :post, 'update_section', update_request
          expect(response.status).to eq(200)
          section.reload
          expect(section.page_items.length).to eql(2)
        end

      end

      describe 'failures' do
        it 'fails without a page param' do
          update_request = { section: { id: section.id, items: [] } }
          # xhr :post, 'update_section', update_request
          # expect(response.status).to eq(200)
          # expect(JSON.parse(response.body)).to include({'success' => false})

          expect {
            xhr :post, 'update_section', update_request
          }.to raise_error(ActionController::UrlGenerationError)
        end

        it 'fails when we dont specify a section' do
          update_request = { id: page.id }
          xhr :post, 'update_section', update_request
          expect(response.status).to eq(500)
          expect(response.body).to match(/Missing section/)
        end

        describe 'when we arent the author' do
          before(:each) do
            sign_out author
          end
          it "fails with not authorized" do
            update_request = { id: page.id, section: { id: section.id, items: [] } }
            xhr :post, 'update_section', update_request
            expect(response.status).to eq(403)
            expect(response.body).to match(/not authorized/i)
          end
        end

      end
    end

    describe "#copy_section" do
      let(:section) { FactoryGirl.create(:section, :with_items, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }

      before :each do
        sign_in author
      end

      describe "success" do
        it "creates a copy with copies of the same items" do
          copy_request = { id: page.id, section_id: section.id }
          xhr :post, 'copy_section', copy_request
          expect(response.status).to eq(200)
          next_pages = JSON.parse(response.body, object_class:OpenStruct)
          expect(next_pages.id).to eq(page.id.to_s)
          expect(next_pages.sections.length).to eq(2)
          next_pages.sections.each do |s|
            expect(s.items.length).to eql(3)
            s.items.each_with_index do |item, index|
              original = section.page_items[index]
              expect(item.data.prompt).to eql(original.embeddable.prompt)
              expect(item.data.name).to eql(original.embeddable.name)
              expect(item.type).to eql(original.embeddable.class.name)
              expect(item.position).to eql(original.position)
              expect(item.column).to eql(original.column)
            end
          end
        end
      end

      describe 'failure' do
        it 'fails without a page param' do
          copy_request = { section_id: section.id }
          # xhr :post, 'copy_section', copy_request
          # expect(response.status).to eq(200)
          # expect(JSON.parse(response.body)).to include( {'success' => false })

          expect {
            xhr :post, 'copy_section', copy_request
          }.to raise_error(ActionController::UrlGenerationError)
        end

        it 'fails when we dont specify a section' do
          copy_request = { id: page.id }
          xhr :post, 'copy_section', copy_request
          expect(response.status).to eq(500)
          expect(response.body).to match(/Missing section/)
        end

        describe 'when we arent the author' do
          before(:each) do
            sign_out author
          end
          it "fails with not authorized" do
            copy_request = { id: page.id, section_id: section.id }
            xhr :post, 'copy_section', copy_request
            expect(response.status).to eq(403)
            expect(response.body).to match(/not authorized/i)
          end
        end
      end
    end


    describe "#copy_page_item" do
      let(:section) { FactoryGirl.create(:section, :with_items, :interactive_page => page, :layout => Section::LAYOUT_FULL_WIDTH) }
      let(:original_item) { section.page_items[0] }
      let(:number_of_items) { section.page_items.length }
      let(:page_id) { page.id }
      let(:page_item_id) { original_item.id }

      before :each do
        sign_in author
      end

      describe "success" do
        it 'creates a copy with copies of the same items' do
          xhr :post, 'copy_page_item', { id: page_id, page_item_id: page_item_id }
          expect(response.status).to eq(200)
          section.reload
          puts response.body
          # expect(section.page_items.length).to eq(number_of_items+1)
          copied_item = JSON.parse(response.body, object_class:OpenStruct)
          puts copied_item
          expect(copied_item.column).to eq(original_item.column)
          expect(copied_item.type).to eq(original_item.embeddable_type)
          expect(copied_item.data.prompt).to eq(original_item.embeddable.prompt)
          expect(copied_item.id).not_to eq(original_item.id)
          expect(copied_item.position).not_to eq(original_item.position)
        end
      end

      describe 'failure' do
        it 'fails without a page param' do
          # xhr :post, 'copy_page_item',  { page_item_id: page_item_id }
          # expect(response.status).to eq(200)
          # expect(JSON.parse(response.body)).to include( {'success' => false })

          expect {
            xhr :post, 'copy_page_item',  { page_item_id: page_item_id }
          }.to raise_error(ActionController::UrlGenerationError)
        end

        it 'fails when we dont specify a page_item' do
          xhr :post, 'copy_page_item',  { id: page_id  }
          expect(response.status).to eq(500)
          expect(response.body).to match(/Missing page_item_id/)
        end

        describe 'when we arent the author' do
          before(:each) do
            sign_out author
          end
          it 'fails with not authorized' do
            xhr :post, 'copy_page_item',  { id: page_id, page_item_id: page_item_id }
            expect(response.status).to eq(403)
            expect(response.body).to match(/not authorized/i)
          end
        end
      end

    end


    describe 'deleting items' do
      let(:item_to_delete) { items.last }

      let(:update_request) do
        { id: page.id, page_item_id: item_to_delete.id }
      end

      describe 'success' do
        it 'deletes missing items not present in the items post request' do
          xhr :post, 'delete_page_item', update_request
          expect(response.status).to eq(200)
          section.reload
          expect(section.page_items.length).to eq(2)
          expect(section.page_items.map{ |i| i.id }).not_to include(item_to_delete.id)
        end
      end

      describe 'failure' do
        describe 'when we arent the author' do
          before(:each) do
            sign_out author
          end
          it "fails with not authorized" do
            xhr :post, 'update_section', update_request
            expect(response.status).to eq(403)
            expect(response.body).to match(/not authorized/i)
          end
        end
      end
    end
  end

  describe "#get_portal_list" do
    it "returns an array of OAuth portals including each portal's name and authorization path" do
      allow_any_instance_of(Api::V1::InteractivePagesController).to receive(:user_omniauth_authorize_path).and_return('/auth/foo')
      xhr :get, "get_portal_list"
      expect(response.status).to eq(200)
      expect(response.body).to eql({
        success: true,
        portals: [
            {
              name: "Portal",
              path: "/auth/foo"
            },
            {
              name: "Concord.Portal",
              path: "/auth/foo"
            },
            {
              name: "Portal", # See spec/spec_helper.rb line 54
              path: "/auth/foo"
            }
          ]
        }.to_json
      )
    end
  end

end
