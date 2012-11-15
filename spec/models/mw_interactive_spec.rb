require 'spec_helper'

describe MwInteractive do
  before :each do
    @valid = {
      :name => "mw interactive",
      :url  => "http://www.concord.org",
      :width => 60,
      :native_width => 400,
      :native_height => 200
    }
    @interactive = MwInteractive.create!(@valid)
  end

  it 'has valid attributes' do
    @interactive.name.should == "mw interactive"
    @interactive.url.should  == "http://www.concord.org"
    @interactive.width.should == 60
  end

  it 'can to associate an interactive page' do
    @page = InteractivePage.create!(:name => "page", :text => "some text")
    @page.add_interactive(@interactive)

    @interactive.reload
    @page.reload

    @interactive.interactive_page.should == @page
  end

  # TODO: Need to test aspect ratio and given-width-get-height methods
end
