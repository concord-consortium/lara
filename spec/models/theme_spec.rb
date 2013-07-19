require 'spec_helper'

describe Theme do
  let (:theme) { FactoryGirl.create(:theme) }

  it 'has a name' do
    theme.name.should_not be_blank
  end

  it 'has a CSS filename' do
    theme.css_file.should_not be_blank
  end

  describe '#css_file_exists' do
    it 'returns true if the CSS file exists' do
      File.stub(:exist?).and_return(true)
      theme.css_file_exists?.should be_true
    end

    it 'returns false if the file is not in either search path' do
      File.stub(:exist?).and_return(false)
      theme.css_file_exists?.should_not be_true
    end
  end

  describe "Theme.default" do
    before(:each) do
      Theme.destroy_all
      @existant = Theme.send(:create_default)
    end

    describe "When the default Theme doesn't exist" do
      it "should create a new default Theme" do
        Theme.should_receive(:find_by_name).and_return(nil)
        default = Theme.default
        default.name.should == Theme::DefaultName
        default.should_not == @existant
      end
    end

    describe "When the default Theme already exists" do
      it "should use the one the existing default project" do
        Theme.default.should == @existant
      end
    end
  end

end
