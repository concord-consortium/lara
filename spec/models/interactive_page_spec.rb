require 'spec_helper'

describe InteractivePage do
  let (:page) do
    p = FactoryGirl.create(:page)
    [3,1,2].each do |i|
      embed = FactoryGirl.create(:xhtml, :name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end
  
  it 'has valid attributes' do
    page.valid?
  end

  it 'belongs to a lightweight activity' do
    activity = FactoryGirl.create(:activity)

    page.lightweight_activity = activity
    page.save!

    page.reload

    page.lightweight_activity.should == activity
    activity.pages.size.should == 1
    activity.pages.first.should == page
  end

  it 'has interactives' do
    # The factory has an interactive by default
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive)
      page.add_interactive(inter, i)
    end
    page.reload

    page.interactives.size.should == 4 
  end

  it 'has interactives in the correct order' do
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive, :name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      page.add_interactive(inter, i)
    end
    page.reload

    page.interactives[1].url.should == "http://www.concord.org/1"
    page.interactives.last.name.should == "inter 3"
  end

  it 'has embeddables' do
    page.embeddables.size.should == 3
  end

  it 'has embeddables in the correct order' do
    page.embeddables.first.content.should == "This is the 1st embeddable"
    page.embeddables.last.name.should == "embeddable 3"
  end

  it 'inserts embeddables at the end if position is not provided' do
    embed_count = page.embeddables.length
    embed4 = FactoryGirl.create(:xhtml, :name => 'Embeddable 4')
    page.add_embeddable(embed4)
    page.reload

    page.embeddables.length.should == embed_count + 1
    page.embeddables.first.content.should == "This is the 1st embeddable"
    page.embeddables.last.name.should == "Embeddable 4"
  end


  it 'adds a new MwInteractive when show_interactive is set to true' do
    int_count = page.interactives.length
    page.show_interactive = "1"
    page.save
    page.reload
    page.interactives.length.should > 0
  end
end
