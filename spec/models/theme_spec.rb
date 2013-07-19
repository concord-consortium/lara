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
    subject    { Theme.default }
    its(:name) { should == Theme::DefaultName}
  end

end
