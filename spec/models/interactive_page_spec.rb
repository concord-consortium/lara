require 'spec_helper'

describe InteractivePage do
  before :each do
    @valid = {
      :name => "Page",
      :text => "Some text"
    }
    @page = InteractivePage.create!(@valid)
    [3,1,2].each do |i|
      embed = Embeddable::Xhtml.create!(:name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      @page.add_embeddable(embed, i)
    end
  end

  it 'should have valid attributes' do
    @page.name.should == "Page"
    @page.text.should == "Some text"
  end

  it 'should belong to a lightweight activity' do
    @activity = LightweightActivity.create!(:name => "Activity")

    @page.lightweight_activity = @activity
    @page.save!

    @page.reload

    @page.lightweight_activity.should == @activity
    @activity.pages.size.should == 1
    @activity.pages.first.should == @page
  end

  it 'should have interactives' do
    [3,1,2].each do |i|
      inter = MwInteractive.create!(:name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      @page.add_interactive(inter, i)
    end
    @page.reload

    @page.interactives.size.should == 3
  end

  it 'should have interactives in the correct order' do
    [3,1,2].each do |i|
      inter = MwInteractive.create!(:name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      @page.add_interactive(inter, i)
    end
    @page.reload

    @page.interactives.first.url.should == "http://www.concord.org/1"
    @page.interactives.last.name.should == "inter 3"
  end

  it 'should have embeddables' do
    @page.embeddables.size.should == 3
  end

  it 'should have embeddables in the correct order' do
    @page.embeddables.first.content.should == "This is the 1st embeddable"
    @page.embeddables.last.name.should == "embeddable 3"
  end

  it 'should insert embeddables at the end if position is not provided' do
    embed_count = @page.embeddables.length
    embed4 = Embeddable::Xhtml.create!(:name => "Embeddable 4", :content => "This is the 4th embeddable")
    @page.add_embeddable(embed4)
    @page.reload

    @page.embeddables.length.should == embed_count + 1
    @page.embeddables.first.content.should == "This is the 1st embeddable"
    @page.embeddables.last.name.should == "Embeddable 4"
  end


  it 'adds a new MwInteractive when show_interactive is set to true' do
    int_count = @page.interactives.length
    @page.show_interactive = "1"
    @page.save
    @page.reload
    @page.interactives.length.should > 0
  end
end
