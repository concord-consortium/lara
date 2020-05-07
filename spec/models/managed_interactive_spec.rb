require 'spec_helper'

describe ManagedInteractive do
  let(:library_interactive) { FactoryGirl.create(:library_interactive,
                                                 :name => 'Test Library managed_Interactive',
                                                 :base_url => 'http://concord.org/',
                                                 :aspect_ratio_method => "base aspect_ratio_method",
                                                 :native_width => 100,
                                                 :native_height => 200,
                                                 :click_to_play => true,
                                                 :full_window => true,
                                                 :click_to_play_prompt => "base click_to_play_prompt",
                                                 :image_url => "http://base.url/image",
                                                 :enable_learner_state => true,
                                                 :show_delete_data_button => false,
                                                 :has_report_url => true,
                                                 :no_snapshots => true
                                                )}

  let(:managed_interactive) { FactoryGirl.create(:managed_interactive,
                                                 :library_interactive => library_interactive,
                                                 :url_fragment => "test"
                                                )}
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    managed_interactive.valid?
  end

  it 'can to associate an interactive page' do
    page.add_interactive(managed_interactive)

    managed_interactive.reload
    page.reload

    expect(managed_interactive.interactive_page).to eq(page)
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = {
        library_interactive_id: managed_interactive.library_interactive_id,
        name: managed_interactive.name,
        url_fragment: managed_interactive.url_fragment,
        authored_state: managed_interactive.authored_state,
        is_hidden: managed_interactive.is_hidden,
        is_full_width: managed_interactive.is_full_width,
        show_in_featured_question_report: managed_interactive.show_in_featured_question_report,
        inherit_aspect_ratio_method: managed_interactive.inherit_aspect_ratio_method,
        custom_aspect_ratio_method: managed_interactive.custom_aspect_ratio_method,
        inherit_native_width: managed_interactive.inherit_native_width,
        custom_native_width: managed_interactive.custom_native_width,
        inherit_native_height: managed_interactive.inherit_native_height,
        custom_native_height: managed_interactive.custom_native_height,
        inherit_click_to_play: managed_interactive.inherit_click_to_play,
        custom_click_to_play: managed_interactive.custom_click_to_play,
        inherit_full_window: managed_interactive.inherit_full_window,
        custom_full_window: managed_interactive.custom_full_window,
        inherit_click_to_play_prompt: managed_interactive.inherit_click_to_play_prompt,
        custom_click_to_play_prompt: managed_interactive.custom_click_to_play_prompt,
        inherit_image_url: managed_interactive.inherit_image_url,
        custom_image_url: managed_interactive.custom_image_url
       }
      expect(managed_interactive.to_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'is a new instance of MwInteractive with values' do
      managed_interactive.is_hidden = true
      expect(managed_interactive.duplicate).to be_a_new(ManagedInteractive).with({
        library_interactive_id: managed_interactive.library_interactive_id,
        name: managed_interactive.name,
        url_fragment: managed_interactive.url_fragment,
        authored_state: managed_interactive.authored_state,
        is_hidden: managed_interactive.is_hidden,
        is_full_width: managed_interactive.is_full_width,
        show_in_featured_question_report: managed_interactive.show_in_featured_question_report,
        inherit_aspect_ratio_method: managed_interactive.inherit_aspect_ratio_method,
        custom_aspect_ratio_method: managed_interactive.custom_aspect_ratio_method,
        inherit_native_width: managed_interactive.inherit_native_width,
        custom_native_width: managed_interactive.custom_native_width,
        inherit_native_height: managed_interactive.inherit_native_height,
        custom_native_height: managed_interactive.custom_native_height,
        inherit_click_to_play: managed_interactive.inherit_click_to_play,
        custom_click_to_play: managed_interactive.custom_click_to_play,
        inherit_full_window: managed_interactive.inherit_full_window,
        custom_full_window: managed_interactive.custom_full_window,
        inherit_click_to_play_prompt: managed_interactive.inherit_click_to_play_prompt,
        custom_click_to_play_prompt: managed_interactive.custom_click_to_play_prompt,
        inherit_image_url: managed_interactive.inherit_image_url,
        custom_image_url: managed_interactive.custom_image_url
      })
    end
  end

  describe "#portal_hash" do
    it 'returns properties supported by Portal' do
      expect(managed_interactive.portal_hash).to include(
        type: 'iframe_interactive',
        id: managed_interactive.id,
        display_in_iframe: managed_interactive.reportable_in_iframe?,

        library_interactive_id: managed_interactive.library_interactive_id,
        name: managed_interactive.name,
        url_fragment: managed_interactive.url_fragment,
        authored_state: managed_interactive.authored_state,
        is_hidden: managed_interactive.is_hidden,
        is_full_width: managed_interactive.is_full_width,
        show_in_featured_question_report: managed_interactive.show_in_featured_question_report,
        inherit_aspect_ratio_method: managed_interactive.inherit_aspect_ratio_method,
        custom_aspect_ratio_method: managed_interactive.custom_aspect_ratio_method,
        inherit_native_width: managed_interactive.inherit_native_width,
        custom_native_width: managed_interactive.custom_native_width,
        inherit_native_height: managed_interactive.inherit_native_height,
        custom_native_height: managed_interactive.custom_native_height,
        inherit_click_to_play: managed_interactive.inherit_click_to_play,
        custom_click_to_play: managed_interactive.custom_click_to_play,
        inherit_full_window: managed_interactive.inherit_full_window,
        custom_full_window: managed_interactive.custom_full_window,
        inherit_click_to_play_prompt: managed_interactive.inherit_click_to_play_prompt,
        custom_click_to_play_prompt: managed_interactive.custom_click_to_play_prompt,
        inherit_image_url: managed_interactive.inherit_image_url,
        custom_image_url: managed_interactive.custom_image_url
      )
    end
  end

  describe "#import" do
    it 'imports what is exported' do
      exported = managed_interactive.export()
      imported = ManagedInteractive.import(exported)
      expect(imported.export()).to eq exported

      # tests if the existing library interactive is loaded
      expect(imported.library_interactive_id).not_to be_nil
      expect(imported.library_interactive_id).to be managed_interactive.library_interactive_id
    end

    it 'creates a new library interactive if export_hash not found' do
      managed_interactive.library_interactive.name = "This doesn't exist in the database"
      imported = ManagedInteractive.import(managed_interactive.export())
      expect(imported.export()).to eq managed_interactive.export()

      # tests if a new library interactive is created
      expect(imported.library_interactive_id).to be_nil
      imported.save
      expect(imported.library_interactive_id).not_to be managed_interactive.library_interactive_id
      expect(imported.library_interactive_id).to be > managed_interactive.library_interactive_id
    end

    it 'does not create duplicate new library interactives if export_hash not found' do
      managed_interactive.library_interactive.name = "This doesn't exist in the database"
      exported = managed_interactive.export()
      imported1 = ManagedInteractive.import(exported)
      imported2 = ManagedInteractive.import(exported)
      expect(imported1.export()).to eq managed_interactive.export()
      expect(imported2.export()).to eq managed_interactive.export()

      # tests if a new library interactive is created
      expect(imported1.library_interactive_id).to be_nil
      expect(imported2.library_interactive_id).not_to be_nil  # the import saves the library interactive
      imported1.save
      expect(imported1.library_interactive_id).to be imported2.library_interactive_id
      expect(imported1.library_interactive_id).not_to be managed_interactive.library_interactive_id
      expect(imported1.library_interactive_id).to be > managed_interactive.library_interactive_id
    end
  end

  describe "portal_type" do
    it "returns iframe interactive like mw_interactive does" do
      expect(ManagedInteractive.portal_type).to eq "iframe interactive"
    end
  end

  describe "validation" do

    it "ensures custom_native_width is valid" do
      managed_interactive.custom_native_width = 100
      expect(managed_interactive).to be_valid
      managed_interactive.custom_native_width = "not an number"
      expect(managed_interactive).not_to be_valid
    end

    it "ensures custom_native_height is valid" do
      managed_interactive.custom_native_height = 100
      expect(managed_interactive).to be_valid
      managed_interactive.custom_native_height = "not an number"
      expect(managed_interactive).not_to be_valid
    end
  end

  describe "inheritance methods" do
    # NOTE: all the inherit_* attributes default to true and are tested for that along with testing if the library_interactive is nil

    it "concats the url" do
      expect(managed_interactive.url).to eq 'http://concord.org/test'
      managed_interactive.library_interactive = nil
      expect(managed_interactive.url).to eq nil
    end

    it "returns aspect_ratio_method" do
      expect(managed_interactive.aspect_ratio_method).to eq library_interactive.aspect_ratio_method
      managed_interactive.custom_aspect_ratio_method = "custom aspect_ratio_method"
      expect(managed_interactive.aspect_ratio_method).to eq library_interactive.aspect_ratio_method
      managed_interactive.inherit_aspect_ratio_method = false
      expect(managed_interactive.aspect_ratio_method).to eq "custom aspect_ratio_method"
      managed_interactive.inherit_aspect_ratio_method = true
      expect(managed_interactive.aspect_ratio_method).to eq library_interactive.aspect_ratio_method
      managed_interactive.library_interactive = nil
      expect(managed_interactive.aspect_ratio_method).to eq "custom aspect_ratio_method"
    end

    it "returns native_width" do
      expect(managed_interactive.native_width).to eq library_interactive.native_width
      managed_interactive.custom_native_width = library_interactive.native_width * 2
      expect(managed_interactive.native_width).to eq library_interactive.native_width
      managed_interactive.inherit_native_width = false
      expect(managed_interactive.native_width).to eq library_interactive.native_width * 2
      managed_interactive.inherit_native_width = true
      expect(managed_interactive.native_width).to eq library_interactive.native_width
      managed_interactive.library_interactive = nil
      expect(managed_interactive.native_width).to eq library_interactive.native_width * 2
    end

    it "returns native_height" do
      expect(managed_interactive.native_height).to eq library_interactive.native_height
      managed_interactive.custom_native_height = library_interactive.native_height * 2
      expect(managed_interactive.native_height).to eq library_interactive.native_height
      managed_interactive.inherit_native_height = false
      expect(managed_interactive.native_height).to eq library_interactive.native_height * 2
      managed_interactive.inherit_native_height = true
      expect(managed_interactive.native_height).to eq library_interactive.native_height
      managed_interactive.library_interactive = nil
      expect(managed_interactive.native_height).to eq library_interactive.native_height * 2
    end

    it "returns click_to_play" do
      expect(managed_interactive.click_to_play).to eq library_interactive.click_to_play
      managed_interactive.custom_click_to_play = !library_interactive.click_to_play
      expect(managed_interactive.click_to_play).to eq library_interactive.click_to_play
      managed_interactive.inherit_click_to_play = false
      expect(managed_interactive.click_to_play).to eq !library_interactive.click_to_play
      managed_interactive.inherit_click_to_play = true
      expect(managed_interactive.click_to_play).to eq library_interactive.click_to_play
      managed_interactive.library_interactive = nil
      expect(managed_interactive.click_to_play).to eq !library_interactive.click_to_play
    end

    it "returns full_window" do
      expect(managed_interactive.full_window).to eq library_interactive.full_window
      managed_interactive.custom_full_window = !library_interactive.full_window
      expect(managed_interactive.full_window).to eq library_interactive.full_window
      managed_interactive.inherit_full_window = false
      expect(managed_interactive.full_window).to eq !library_interactive.full_window
      managed_interactive.inherit_full_window = true
      expect(managed_interactive.full_window).to eq library_interactive.full_window
      managed_interactive.library_interactive = nil
      expect(managed_interactive.full_window).to eq !library_interactive.full_window
    end

    it "returns click_to_play_prompt" do
      expect(managed_interactive.click_to_play_prompt).to eq library_interactive.click_to_play_prompt
      managed_interactive.custom_click_to_play_prompt = "custom click_to_play_prompt"
      expect(managed_interactive.click_to_play_prompt).to eq library_interactive.click_to_play_prompt
      managed_interactive.inherit_click_to_play_prompt = false
      expect(managed_interactive.click_to_play_prompt).to eq "custom click_to_play_prompt"
      managed_interactive.inherit_click_to_play_prompt = true
      expect(managed_interactive.click_to_play_prompt).to eq library_interactive.click_to_play_prompt
      managed_interactive.library_interactive = nil
      expect(managed_interactive.click_to_play_prompt).to eq "custom click_to_play_prompt"
    end

    it "returns image_url" do
      expect(managed_interactive.image_url).to eq library_interactive.image_url
      managed_interactive.custom_image_url = "custom image_url"
      expect(managed_interactive.image_url).to eq library_interactive.image_url
      managed_interactive.inherit_image_url = false
      expect(managed_interactive.image_url).to eq "custom image_url"
      managed_interactive.inherit_image_url = true
      expect(managed_interactive.image_url).to eq library_interactive.image_url
      managed_interactive.library_interactive = nil
      expect(managed_interactive.image_url).to eq "custom image_url"
    end
  end

  describe "proxied methods" do
    it "returns enable_learner_state" do
      expect(library_interactive.enable_learner_state).to be true
      expect(managed_interactive.enable_learner_state).to eq library_interactive.enable_learner_state
      # without a library interactive it defaults to false
      managed_interactive.library_interactive = nil
      expect(managed_interactive.enable_learner_state).to be false
    end

    it "returns show_delete_data_button" do
      expect(library_interactive.show_delete_data_button).to be false
      expect(managed_interactive.show_delete_data_button).to eq library_interactive.show_delete_data_button
      # without a library interactive it defaults to true
      managed_interactive.library_interactive = nil
      expect(managed_interactive.show_delete_data_button).to be true
    end

    it "returns has_report_url" do
      expect(library_interactive.has_report_url).to be true
      expect(managed_interactive.has_report_url).to eq library_interactive.has_report_url
      # without a library interactive it defaults to false
      managed_interactive.library_interactive = nil
      expect(managed_interactive.has_report_url).to be false
    end

    it "returns no_snapshots" do
      expect(library_interactive.no_snapshots).to be true
      expect(managed_interactive.no_snapshots).to eq library_interactive.no_snapshots
      # without a library interactive it defaults to false
      managed_interactive.library_interactive = nil
      expect(managed_interactive.no_snapshots).to be false
    end
  end
end
