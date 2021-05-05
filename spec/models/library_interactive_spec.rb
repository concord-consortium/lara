require 'spec_helper'

describe LibraryInteractive do
  let(:library_interactive) { FactoryGirl.create(:library_interactive) }

  describe '#to_hash' do
    it 'has useful values' do
      expected = {
        aspect_ratio_method: library_interactive.aspect_ratio_method,
        authoring_guidance: library_interactive.authoring_guidance,
        base_url: library_interactive.base_url,
        click_to_play: library_interactive.click_to_play,
        click_to_play_prompt: library_interactive.click_to_play_prompt,
        description: library_interactive.description,
        enable_learner_state: library_interactive.enable_learner_state,
        full_window: library_interactive.full_window,
        has_report_url: library_interactive.has_report_url,
        image_url: library_interactive.image_url,
        name: library_interactive.name,
        native_height: library_interactive.native_height,
        native_width: library_interactive.native_width,
        no_snapshots: library_interactive.no_snapshots,
        show_delete_data_button: library_interactive.show_delete_data_button,
        thumbnail_url: library_interactive.thumbnail_url,
        customizable: library_interactive.customizable,
        authorable: library_interactive.authorable
       }
      expect(library_interactive.to_hash).to eq(expected)
    end
  end

  describe "#import" do
    it 'imports what is exported' do
      exported = library_interactive.export()
      imported = LibraryInteractive.import(exported)
      expect(imported.export()).to eq exported
    end
  end

  describe "export_hash" do
    let(:library_interactive_via_build) { FactoryGirl.build(:library_interactive) }

    it "is set on create" do
      expect(library_interactive.export_hash).not_to be_nil
      expect(library_interactive.export_hash).to eq(library_interactive.generate_export_hash())
    end

    it "is empty on build" do
      expect(library_interactive_via_build.export_hash).to be_nil
    end
  end

  describe "validation" do

    it "ensures name is present" do
      library_interactive.name = "Name"
      expect(library_interactive).to be_valid
      library_interactive.name = ""
      expect(library_interactive).not_to be_valid
    end

    it "ensures base_url is present and valid" do
      library_interactive.base_url = "https://valid.url"
      expect(library_interactive).to be_valid
      library_interactive.base_url = ""
      expect(library_interactive).not_to be_valid
    end

    it "ensures image_url is valid if present" do
      library_interactive.image_url = "https://valid.url"
      expect(library_interactive).to be_valid
      library_interactive.image_url = ""
      expect(library_interactive).to be_valid
      library_interactive.image_url = "not an url"
      expect(library_interactive).not_to be_valid
    end

    it "ensures thumbnail_url is valid if present" do
      library_interactive.thumbnail_url = "https://valid.url"
      expect(library_interactive).to be_valid
      library_interactive.thumbnail_url = ""
      expect(library_interactive).to be_valid
      library_interactive.thumbnail_url = "not an url"
      expect(library_interactive).not_to be_valid
    end

    it "ensures native_width is valid" do
      library_interactive.native_width = 100
      expect(library_interactive).to be_valid
      library_interactive.native_width = "not an number"
      expect(library_interactive).not_to be_valid
    end

    it "ensures native_height is valid" do
      library_interactive.native_height = 100
      expect(library_interactive).to be_valid
      library_interactive.native_height = "not an number"
      expect(library_interactive).not_to be_valid
    end
  end

  describe "#use_count" do
    it 'returns the number of managed interactives that use the library interactive' do
      expect(library_interactive.use_count()).to eq(0)
      managed_interactive = FactoryGirl.create(:managed_interactive,
                                                :library_interactive => library_interactive
                                               )
      expect(library_interactive.use_count()).to eq(1)
    end
  end
end
