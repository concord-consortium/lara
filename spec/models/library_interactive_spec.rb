require 'spec_helper'

describe LibraryInteractive do
  let(:library_interactive) { FactoryGirl.create(:library_interactive) }

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
end
