require 'spec_helper'

def find_labbook(i_page)
  i_page.embeddables.select {|e| e.is_a? Embeddable::Labbook} [0]
end

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
      expect(page.valid?).to be_truthy # Ugh, but HTML not XML
      page.text = 'This HTML is valid.'
      page.valid?
    end

    it 'rejects invalid HTML for the sidebar' do
      page.sidebar = '<p class="invalid-attribute>This has an invalid attribute.</p>'
      expect(page.valid?).to be_falsey
      page.sidebar = '<p class="valid-attribute">Much better.</p>'
      page.valid?
    end

    it 'rejects empty sidebar titles' do
      page.sidebar_title = ""
      expect(page).not_to be_valid
      page.sidebar_title = "   "
      expect(page).not_to be_valid
      page.sidebar_title = nil
      expect(page).not_to be_valid
    end
    it 'accepts non blank sidebar titles' do
      page.sidebar_title = "sidebar"
      expect(page).to be_valid
    end
  end

  describe 'default values' do
    subject { InteractivePage.new }

    describe '#sidebar_title' do
      subject { super().sidebar_title }
      it { is_expected.to eq("Did you know?") }
    end
  end

  describe 'layouts' do
    it 'has an array of hashes describing valid layouts' do
      expect(InteractivePage::LAYOUT_OPTIONS.length).to be > 0
    end

    it 'does not validate with layouts not in the hash' do
      page.layout = 'invalid-layout-string'
      expect(page.valid?).to be_falsey
    end
  end

  describe 'embeddable display modes' do
    it 'has an array of strings which are valid as embeddable display modes' do
      expect(InteractivePage::EMBEDDABLE_DISPLAY_OPTIONS.length).to be > 0
    end

    it 'does not validate with modes not in the array' do
      page.embeddable_display_mode = 'invalid-display-mode'
      expect(page.valid?).to be_falsey
    end
  end

  it 'belongs to a lightweight activity' do
    activity = FactoryGirl.create(:activity)

    page.lightweight_activity = activity
    page.save!

    page.reload

    expect(page.lightweight_activity).to eq(activity)
    expect(activity.pages.size).to eq(1)
    expect(activity.pages.first).to eq(page)
  end

  it 'has interactives' do
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive)
      page.add_interactive(inter, i)
    end
    page.reload

    expect(page.interactives.size).to eq(3)
  end

  it 'has interactives in the correct order' do
    # We're adding these with a "position" parameter, so they're being added as 3, 1, 2 but the order should be 1, 2, 3
    [3,1,2].each do |i|
      inter = FactoryGirl.create(:mw_interactive, :name => "inter #{i}", :url => "http://www.concord.org/#{i}")
      page.add_interactive(inter, i)
    end
    page.reload

    expect(page.interactives[1].url).to eq("http://www.concord.org/2")
    expect(page.interactives.last.name).to eq("inter 3")
  end

  it 'has embeddables' do
    expect(page.embeddables.size).to eq(3)
  end

  it 'has embeddables in the correct order' do
    expect(page.embeddables.first.content).to eq("This is the 1st embeddable")
    expect(page.embeddables.last.name).to eq("embeddable 3")
  end

  it 'inserts embeddables at the end if position is not provided' do
    embed_count = page.embeddables.length
    embed4 = FactoryGirl.create(:xhtml, :name => 'Embeddable 4')
    page.add_embeddable(embed4)
    page.reload

    expect(page.embeddables.length).to eq(embed_count + 1)
    expect(page.embeddables.first.content).to eq("This is the 1st embeddable")
    expect(page.embeddables.last.name).to eq("Embeddable 4")
  end

  describe 'helpers related to order of pages should respect is_hidden value' do
    let (:activity) { FactoryGirl.create(:activity_with_pages, pages_count: 4) }

    context 'when no pages are hidden' do
      it 'order is based on pages position' do
        expect(activity.pages[0].first_visible?).to be_truthy
        expect(activity.pages[0].prev_visible_page).to be_nil
        expect(activity.pages[1].first_visible?).to be_falsey
        expect(activity.pages[1].prev_visible_page).to eql(activity.pages[0])
        expect(activity.pages[2].last_visible?).to be_falsey
        expect(activity.pages[2].next_visible_page).to eql(activity.pages[3])
        expect(activity.pages[3].next_visible_page).to be_nil
        expect(activity.pages[3].last_visible?).to be_truthy
      end
    end

    context 'when some pages are hidden' do
      before(:each) do
        activity.pages.first.update_attributes!(is_hidden: true)
        activity.pages.last.update_attributes!(is_hidden: true)
      end
      it 'order is based on pages position and is_hidden values' do
        expect(activity.pages[0].first_visible?).to be_falsey
        expect(activity.pages[0].prev_visible_page).to be_nil
        expect(activity.pages[1].first_visible?).to be_truthy
        expect(activity.pages[1].prev_visible_page).to be_nil
        expect(activity.pages[2].last_visible?).to be_truthy
        expect(activity.pages[2].next_visible_page).to be_nil
        expect(activity.pages[3].next_visible_page).to be_nil
        expect(activity.pages[3].last_visible?).to be_falsey
      end
    end
  end

  describe '#to_hash' do
    it 'has values from the source instance' do
      expected = {
        name: page.name,
        position: page.position,
        text: page.text,
        layout: page.layout,
        is_hidden: page.is_hidden,
        sidebar: page.sidebar,
        sidebar_title: page.sidebar_title,
        show_introduction: page.show_introduction,
        show_sidebar: page.show_sidebar,
        show_interactive: page.show_interactive,
        show_info_assessment: page.show_info_assessment,
        embeddable_display_mode: page.embeddable_display_mode,
        additional_sections: page.additional_sections
      }
      expect(page.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    it 'returns json of an interactive page' do
      page_json = page.export.as_json
      expect(page_json['interactives'].length).to eq(page.interactives.count)
      expect(page_json['embeddables'].length).to eq(page.embeddables.count)
      expect(page_json['is_hidden']).to eq(page.is_hidden)
    end

    describe "with a labbook" do
      let(:interactive)       { MwInteractive.create()           }
      let(:args)              { {interactive: interactive}       }
      let(:labbook)           { Embeddable::Labbook.create(args) }

      before(:each) do
        page.add_interactive interactive
        page.add_embeddable labbook
        page.reload
      end

      it "should include the references to the interactive in the labbok" do
        expect(interactive).not_to be_nil
        expect(labbook.interactive).not_to be_nil
        export_data = page.export.as_json
        interactive_id = export_data['interactives'].first['ref_id']
        expect(export_data['embeddables'].last).to match a_hash_including('interactive_ref_id' => interactive_id)
      end
    end
  end

  describe '#duplicate' do
    it 'returns a new page with values from the source instance' do
      dupe = page.duplicate
      expect(dupe).to be_a(InteractivePage)
      expect(dupe.name).to eq(page.name)
      expect(dupe.text).to eq(page.text)
      expect(dupe.is_hidden).to eq(page.is_hidden)
      expect(dupe.sidebar_title).to eq(page.sidebar_title)
    end

    it 'has copies of the original interactives' do
      dupe = page.duplicate
      expect(dupe.reload.interactives.length).to be(page.interactives.length)
    end

    it 'has copies of the original embeddables' do
      # Note that this only confirms that there are the same number of embeddables. Page starts with 3.
      expect(page.duplicate.embeddables.length).to be(page.embeddables.length)
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
        expect(page).not_to be_valid
      end
      it "should have the same number of embeddables" do
        expect(page.duplicate.embeddables.length).to be(page.embeddables.length)
      end
      it "should have the same number of interactives as the original" do
        expect(page.duplicate.interactives.length).to be(page.interactives.length)
      end
    end

    describe 'copies of the original interactives' do
      let(:hidden_image)    { FactoryGirl.create(:image_interactive, is_hidden: true)}
      let(:hidden_mw)       { FactoryGirl.create(:mw_interactive, is_hidden: true)}
      let(:hidden_video)    { FactoryGirl.create(:video_interactive, is_hidden: true)}
      let(:dupe)            { page.duplicate.reload}
      before(:each) do
        page.add_interactive hidden_image
        page.add_interactive hidden_mw
        page.add_interactive hidden_video
        page.reload
      end
      it "should have the same number of interactives as the original" do
        dupe.interactives.length.should be(page.interactives.length)
      end

      it "should have copies of interactives with the same visibility" do
        page.interactives.each_with_index do |original,i|
          interactive_copy = dupe.interactives[i]
          expect(original.is_hidden?).to eq interactive_copy.is_hidden?
        end
      end
    end

    describe 'has copies of the original embeddables' do
      let(:hidden_text)    { FactoryGirl.create(:xhtml, is_hidden: true)}
      let(:hidden_labbook) { FactoryGirl.create(:labbook, is_hidden: true)}
      let(:dupe)           { page.duplicate.reload}
      before(:each) do
        page.add_embeddable hidden_labbook
        page.add_embeddable hidden_text
      end

      it "should have the same number of embeddables" do
        expect(dupe.embeddables.length).to be(page.embeddables.length)
      end

      it "should have embeddables of the same visibility as the original" do
        page.embeddables.each_with_index do |original,i|
          copy_emb = dupe.embeddables[i]
          expect(original.is_hidden?).to eq copy_emb.is_hidden?
        end
      end
    end


    describe "copying a labbook with a reference to an interactive" do
      before(:each) do
        page.add_embeddable labbook
      end

      let(:args)              { {interactive: page_interactive}  }
      let(:labbook)           { Embeddable::Labbook.new(args)    }

      let(:dupe)              { page.duplicate       }
      let(:page_interactive)  { page.interactives[0] }
      let(:dupe_interactive)  { dupe.interactives[0] }

      let(:page_labbook) { find_labbook(page) }
      let(:dupe_labbook) { find_labbook(dupe) }

      describe "the original page" do
        it "should have a labbook" do
          expect(page_labbook).not_to be_nil
        end
        it "the labbook should point at the interactive" do
          expect(page_labbook.interactive).to eql (page_interactive)
        end
      end

      describe "the duplcate after a copy" do
        it "should have a labook" do
          expect(dupe_labbook).not_to be_nil
        end
        it "the labook should point at the new interactive" do
          expect(dupe_labbook.interactive).to eql (dupe_interactive)
        end
      end
    end
  end

  describe '#import' do
    it 'imports page from json' do
      activity_json = JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json'), :symbolize_names => true)
      activity_json[:pages].each_with_index do |p, i|
        page = InteractivePage.import(p)
        expect(page).to be_a(InteractivePage)
        expect(p[:name]).to eq(page.name)
        expect(p[:text]).to eq(page.text)
        expect(p[:sidebar_title]).to eq(page.sidebar_title)
        expect(p[:position]).to be(page.position)
      end
      # Test last page for interactive and labbook combo
      page = InteractivePage.import(activity_json[:pages].last).reload
      expect(page.interactives.first).to be_a ImageInteractive
      expect(page.embeddables.first.interactive).to eq page.interactives.first
    end
  end

  describe 'InteractivePage#register_additional_section' do
    before(:all) do
      InteractivePage.register_additional_section({name:  'test_section',
                                                   dir:   'dir',
                                                   label: 'label'})
    end
    it 'should add new methods (show_<secion_name_)' do
      expect(page).not_to respond_to(:show_unexisting_section)
      expect(page).to respond_to(:show_test_section)
      expect(page).to respond_to(:show_test_section=)
    end
  end

  describe "#show_multiple_interactives?" do
    let(:single_page){ LightweightActivity::LAYOUT_SINGLE_PAGE }
    let(:multi_page) { LightweightActivity::LAYOUT_MULTI_PAGE }
    let(:layout)     { nil }
    let(:activity)   { mock_model(LightweightActivity, { layout: layout })     }
    let(:page)       { InteractivePage.new( { lightweight_activity: activity })}

    describe "When the activity is using single page layout" do
      let(:layout) { single_page }
      it "should show multiple interactives on one page" do
        expect(page.show_multiple_interactives?).to eq true
      end
    end

    describe "When the activity is using multi-page layout" do
      let(:layout) { multi_page }
      it "should NOT show multiple interactives on one page" do
        expect(page.show_multiple_interactives?).to eq false
      end
    end
  end
end
