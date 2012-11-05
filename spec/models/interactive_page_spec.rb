require 'spec_helper'

describe Lightweight::InteractivePage do
  before :each do
    @valid = {
      :name => "Page",
      :text => "Some text"
    }
    @page = Lightweight::InteractivePage.create!(@valid)
  end

  it 'should have valid attributes' do
    @page.name.should == "Page"
    @page.text.should == "Some text"
  end

  it 'should belong to a lightweight activity' do
    @activity = Lightweight::LightweightActivity.create!(:name => "Activity")

    @page.lightweight_activity = @activity
    @page.save!

    @page.reload

    @page.lightweight_activity.should == @activity
    @activity.pages.size.should == 1
    @activity.pages.first.should == @page
  end

  it 'should have interactives' do
    [3,1,2].each do |i|
      inter = Lightweight::MwInteractive.create!(:name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      @page.add_interactive(inter, i)
    end
    @page.reload

    @page.interactives.size.should == 3
  end

  it 'should have interactives in the correct order' do
    [3,1,2].each do |i|
      inter = Lightweight::MwInteractive.create!(:name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      @page.add_interactive(inter, i)
    end
    @page.reload

    @page.interactives.first.url.should == "http://www.concord.org/1"
    @page.interactives.last.name.should == "inter 3"
  end

  it 'should have embeddables' do
    [3,1,2].each do |i|
      embed = Embeddable::Xhtml.create!(:name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      @page.add_embeddable(embed, i)
    end
    @page.reload

    @page.embeddables.size.should == 3
  end

  it 'should have embeddables in the correct order' do
    [3,1,2].each do |i|
      embed = Embeddable::Xhtml.create!(:name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      @page.add_embeddable(embed, i)
    end
    @page.reload

    @page.embeddables.first.content.should == "This is the 1st embeddable"
    @page.embeddables.last.name.should == "embeddable 3"
  end

  it 'should insert embeddables at the end if position is not provided' do
    [2,3,1].each do |i|
      embed = Embeddable::Xhtml.create!(:name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      @page.add_embeddable(embed)
    end
    embed4 = Embeddable::Xhtml.create!(:name => "Embeddable 4", :content => "This is the 4th embeddable")
    @page.add_embeddable(embed4)
    @page.reload

    @page.embeddables.first.content.should == "This is the 2nd embeddable"
    @page.embeddables.last.name.should == "Embeddable 4"
  end
end
