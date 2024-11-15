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
        hide_question_number: library_interactive.hide_question_number,
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
        authorable: library_interactive.authorable,
        report_item_url: library_interactive.report_item_url
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

  describe "generate_export_hash" do
    it "returns a hash value based on only certain properties" do
      library_interactives = FactoryGirl.create_list(:library_interactive, 3,
                                                     aspect_ratio_method: "DEFAULT",
                                                     authoring_guidance: "",
                                                     base_url: "https://fake.url",
                                                     click_to_play: false,
                                                     click_to_play_prompt: nil,
                                                     description: "This is my beautiful description.",
                                                     enable_learner_state: true,
                                                     full_window: false,
                                                     has_report_url: false,
                                                     image_url: nil,
                                                     name: "MC Question",
                                                     native_height: 435,
                                                     native_width: 576,
                                                     no_snapshots: false,
                                                     show_delete_data_button: false,
                                                     thumbnail_url: "",
                                                     customizable: false,
                                                     authorable: true
                                                    )

      library_interactives[1].description = "This is not my beautiful description."
      library_interactives[1].authoring_guidance = "Something goes here."
      library_interactives[1].name = "Also an MC Question"
      library_interactives[2].base_url = "https://different.fake.url"

      library_interactive1_hash = library_interactives[0].generate_export_hash()
      library_interactive2_hash = library_interactives[1].generate_export_hash()
      library_interactive3_hash = library_interactives[2].generate_export_hash()

      expect(library_interactive1_hash).not_to eq(nil)
      expect(library_interactive1_hash).to eq(library_interactive2_hash)
      expect(library_interactive1_hash).not_to eq(library_interactive3_hash)
    end
  end

  describe "#use_count" do
    it 'returns the number of managed interactives that use the library interactive' do
      expect(library_interactive.use_count()).to eq(0)
      managed_interactive = FactoryGirl.create(:managed_interactive,
                                                library_interactive: library_interactive
                                               )
      expect(library_interactive.use_count()).to eq(1)
    end
  end
end
