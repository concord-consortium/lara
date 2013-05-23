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

  describe 'layouts' do
    it 'has an array of hashes describing valid layouts' do
      InteractivePage::LAYOUT_OPTIONS.length.should be > 0
    end

    it 'does not validate with layouts not in the hash' do
      page.layout = 'invalid-layout-string'
      page.valid?.should be_false
    end
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

  describe '#to_hash' do
    it 'has values from the source instance' do
      expected = {
        name: page.name,
        position: page.position,
        text: page.text,
        layout: page.layout,
        sidebar: page.sidebar,
        show_introduction: page.show_introduction,
        show_sidebar: page.show_sidebar,
        show_interactive: page.show_interactive,
        show_info_assessment: page.show_info_assessment
      }
      page.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new page with values from the source instance' do
      dupe = page.duplicate
      dupe.should be_a(InteractivePage)
      dupe.name.should == page.name
      dupe.text.should == page.text
    end

    it 'has copies of the original interactives' do
      dupe = page.duplicate
      dupe.reload.interactives.length.should be(page.interactives.length)
    end

    it 'has copies of the original embeddables' do
      # Note that this only confirms that there are the same number of embeddables. Page starts with 3.
      page.duplicate.embeddables.length.should be(page.embeddables.length)
    end
  end
end
