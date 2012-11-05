require 'spec_helper'

describe Lightweight::MwInteractive do
  before :each do
    @valid = {
      :name => "mw interactive",
      :url  => "http://www.concord.org",
      :width => 60
    }
    @interactive = Lightweight::MwInteractive.create!(@valid)
  end

  it 'should have valid attributes' do
    @interactive.name.should == "mw interactive"
    @interactive.url.should  == "http://www.concord.org"
    @interactive.width.should == 60
  end

  it 'should be able to associate an interactive page' do
    @page = Lightweight::InteractivePage.create!(:name => "page", :text => "some text")
    @page.add_interactive(@interactive)

    @interactive.reload
    @page.reload

    @interactive.interactive_page.should == @page
  end

end
