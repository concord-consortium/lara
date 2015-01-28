require 'spec_helper'

describe Theme do
  let (:theme) { FactoryGirl.create(:theme) }

  it 'has a name' do
    expect(theme.name).not_to be_blank
  end

  it 'has a CSS filename' do
    expect(theme.css_file).not_to be_blank
  end

  describe '#css_file_exists' do
    it 'returns true if the CSS file exists' do
      allow(File).to receive(:exist?).and_return(true)
      expect(theme.css_file_exists?).to be_truthy
    end

    it 'returns false if the file is not in either search path' do
      allow(File).to receive(:exist?).and_return(false)
      expect(theme.css_file_exists?).not_to be_truthy
    end
  end

  describe "Theme.default" do
    before(:each) do
      Theme.destroy_all
      @existant = Theme.send(:create_default)
    end

    describe "When the default Theme doesn't exist" do
      it "should create a new default Theme" do
        expect(Theme).to receive(:find_by_name).and_return(nil)
        default = Theme.default
        expect(default.name).to eq(Theme::DefaultName)
        expect(default).not_to eq(@existant)
      end
    end

    describe "When the default Theme already exists" do
      it "should use the one the existing default project" do
        expect(Theme.default).to eq(@existant)
      end
    end
  end

end
