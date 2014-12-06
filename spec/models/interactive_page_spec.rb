require 'spec_helper'

describe InteractivePage do
  let(:page) do
    p = FactoryGirl.create(:page, :sidebar_title => "sidebar")
    [3,1,2].each do |i|
      embed = FactoryGirl.create(:xhtml, :name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end

  it 'has valid attributes' do
    page.valid?
  end

  describe 'validation of HTML inputs' do
    it 'rejects invalid HTML for text' do
      page.text = '<p>This HTML is invalid.<p>Tag soup.</p>'
      page.valid?.should be_true # Ugh, but HTML not XML
      page.text = 'This HTML is valid.'
      page.valid?
    end

    it 'rejects invalid HTML for the sidebar' do
      page.sidebar = '<p class="invalid-attribute>This has an invalid attribute.</p>'
      page.valid?.should be_false
      page.sidebar = '<p class="valid-attribute">Much better.</p>'
      page.valid?
    end

    it 'rejects empty sidebar titles' do
      page.sidebar_title = ""
      page.should_not be_valid
      page.sidebar_title = "   "
      page.should_not be_valid
      page.sidebar_title = nil
      page.should_not be_valid
    end
    it 'accepts non blank sidebar titles' do
      page.sidebar_title = "sidebar"
      page.should be_valid
    end
  end

  describe 'default values' do
    subject { InteractivePage.new }
    its(:sidebar_title) { should == "Did you know?" }
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

  describe 'embeddable display modes' do
    it 'has an array of strings which are valid as embeddable display modes' do
      InteractivePage::EMBEDDABLE_DISPLAY_OPTIONS.length.should be > 0
    end

    it 'does not validate with modes not in the array' do
      page.embeddable_display_mode = 'invalid-display-mode'
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
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive)
      page.add_interactive(inter, i)
    end
    page.reload

    page.interactives.size.should == 3
  end

  it 'has interactives in the correct order' do
    # We're adding these with a "position" parameter, so they're being added as 3, 1, 2 but the order should be 1, 2, 3
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive, :name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      page.add_interactive(inter, i)
    end
    page.reload

    page.interactives[1].url.should == "http://www.concord.org/2"
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

  describe '#to_hash' do
    it 'has values from the source instance' do
      expected = {
        name: page.name,
        position: page.position,
        text: page.text,
        layout: page.layout,
        sidebar: page.sidebar,
        sidebar_title: page.sidebar_title,
        show_introduction: page.show_introduction,
        show_sidebar: page.show_sidebar,
        show_interactive: page.show_interactive,
        show_info_assessment: page.show_info_assessment
      }
      page.to_hash.should == expected
    end
  end

  describe '#export' do
    it 'returns json of an interactive page' do
      page_json = page.export.as_json
      page_json['interactives'].length.should == page.interactives.count
      page_json['embeddables'].length.should == page.embeddables.count
    end
  end

  describe '#duplicate' do
    it 'returns a new page with values from the source instance' do
      dupe = page.duplicate
      dupe.should be_a(InteractivePage)
      dupe.name.should == page.name
      dupe.text.should == page.text
      dupe.sidebar_title.should == page.sidebar_title
    end

    it 'has copies of the original interactives' do
      dupe = page.duplicate
      dupe.reload.interactives.length.should be(page.interactives.length)
    end

    it 'has copies of the original embeddables' do
      # Note that this only confirms that there are the same number of embeddables. Page starts with 3.
      page.duplicate.embeddables.length.should be(page.embeddables.length)
    end

    describe "with invalid markup" do
      before(:each) do
        # Add at least one interactive as it triggers additional .save call
        # during duplication, which should be handled correctly.
        page.add_interactive(FactoryGirl.create(:mw_interactive))
        page.reload
        page.text = "foo</p>"
        page.save(:validate => false)
      end
      it "the page itself should not be valid" do
        page.should_not be_valid
      end
      it 'has copies of the original interactives' do
        dupe = page.duplicate
        # dupe.reload.interactives.length.should be(page.interactives.length)
      end

      it 'has copies of the original embeddables' do
        # Note that this only confirms that there are the same number of embeddables. Page starts with 3.
        page.duplicate.embeddables.length.should be(page.embeddables.length)
      end
    end
  end

  describe '#import' do
    it 'imports page from json' do
      activity_json = JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json'))
      activity_json['pages'].each_with_index do |p, i|
        page = InteractivePage.import(p)
        page.should be_a(InteractivePage)
        p['name'].should == page.name
        p['text'].should == page.text
        p['sidebar_title'].should == page.sidebar_title
        p['position'].should be(page.position)
      end
    end
  end
end
