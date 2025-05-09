require 'spec_helper'

def find_labbook(i_page)
  i_page.embeddables.select {|e| e.is_a? Embeddable::Labbook} [0]
end

describe InteractivePage do
  let(:page) do
    p = FactoryBot.create(:page, sidebar_title: "sidebar")
    [3,1,2].each do |i|
      embed = FactoryBot.create(:xhtml, name: "embeddable #{i}", content: "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end

  it 'has valid attributes' do
    page.valid?
  end

  describe 'validation of HTML inputs' do
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

  describe 'header block' do
    it 'has a header block' do
      expect(page.show_header).to eq(true)
    end

    it 'has a header block to which an embeddable can be added' do
      embed_text = "This is an embeddable in the header block."
      embed = FactoryBot.create(:xhtml, name: "", content: embed_text)
      page.add_embeddable(embed, 1, Section::HEADER_BLOCK)
      page.reload # We have to reload to get the order of page_items correct.
      expect(page.embeddables.size).to eq(4)
      expect(page.page_items.first.section.title).to eq(Section::HEADER_BLOCK)
      expect(page.embeddables.first.content).to eq(embed_text)
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
    activity = FactoryBot.create(:activity)

    page.lightweight_activity = activity
    page.save!

    page.reload

    expect(page.lightweight_activity).to eq(activity)
    expect(activity.pages.size).to eq(1)
    expect(activity.pages.first).to eq(page)
  end

  it 'has interactives' do
    [3,1,2].each do |i|
      inter = FactoryBot.create(:mw_interactive)
      page.add_interactive(inter, i)
    end
    page.reload

    expect(page.interactives.size).to eq(3)
  end

  it 'has interactives in the correct order' do
    # We're adding these with a "position" parameter, so they're being added as 3, 1, 2 but the order should be 1, 2, 3
    [3,1,2].each do |i|
      inter = FactoryBot.create(:mw_interactive, name: "inter #{i}", url: "http://www.concord.org/#{i}")
      page.add_interactive(inter, i)
    end
    page.reload

    expect(page.interactives[1].url).to eq("http://www.concord.org/2")
    expect(page.interactives.last.name).to eq("inter 3")
  end

  it 'has embeddables' do
    expect(page.sections[0].embeddables.length()).to eq(3)
  end

  it 'has embeddables in the correct order' do
    expect(page.sections[0].embeddables.first.content).to eq("This is the 1st embeddable")
    expect(page.sections[0].embeddables.last.name).to eq("embeddable 3")
  end

  it 'inserts embeddables at the end if position is not provided' do
    embed_count = page.sections[0].embeddables.length
    embed4 = FactoryBot.create(:xhtml, name: 'Embeddable 4')
    page.add_embeddable(embed4)
    page.reload

    expect(page.sections[0].embeddables.length).to eq(embed_count + 1)
    expect(page.sections[0].embeddables.first.content).to eq("This is the 1st embeddable")
    expect(page.sections[0].embeddables.last.name).to eq("Embeddable 4")
  end

  describe 'helpers related to order of pages should respect is_hidden value' do
    let (:activity) { FactoryBot.create(:activity_with_pages, pages_count: 4) }

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
        activity.pages.first.update!(is_hidden: true)
        activity.pages.last.update!(is_hidden: true)
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
        layout: page.layout,
        is_hidden: page.is_hidden,
        sidebar: page.sidebar,
        sidebar_title: page.sidebar_title,
        show_header: page.show_header,
        show_sidebar: page.show_sidebar,
        show_interactive: page.show_interactive,
        show_info_assessment: page.show_info_assessment,
        toggle_info_assessment: page.toggle_info_assessment,
        embeddable_display_mode: page.embeddable_display_mode,
        additional_sections: page.additional_sections,
        is_completion: page.is_completion
      }
      expect(page.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    it 'returns json of an interactive page' do
      page_json = page.export.as_json
      expect(page_json['sections'][0]['embeddables'].length).to eq(page.embeddables.count)
      expect(page_json['is_hidden']).to eq(page.is_hidden)
      expect(page_json['is_completion']).to eq(page.is_completion)
      expect(page_json['id']).to eq(page.id)
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
        interactive_box_embeddables = export_data['sections'][1]['embeddables']
        interactive_id = interactive_box_embeddables.first['ref_id']
        labbook = export_data['sections'][0]['embeddables'].find { |e| e["type"] == "Embeddable::Labbook"}
        expect(labbook).to match a_hash_including('interactive_ref_id' => interactive_id)
      end
    end
  end

  describe '#duplicate' do
    it 'returns a new page with values from the source instance' do
      dupe = page.duplicate
      expect(dupe).to be_a(InteractivePage)
      expect(dupe.name).to eq(page.name)
      expect(dupe.is_hidden).to eq(page.is_hidden)
      expect(dupe.sidebar_title).to eq(page.sidebar_title)
      expect(dupe.is_completion).to eq(page.is_completion)
    end

    it 'has copies of the original interactives' do
      dupe = page.duplicate
      expect(dupe.reload.interactives.length).to be(page.interactives.length)
    end

    it 'has copies of the original embeddables' do
      # Note that this only confirms that there are the same number of embeddables. Page starts with 3.
      expect(page.duplicate.sections[0].embeddables.length).to be(page.sections[0].embeddables.length)
    end

    describe 'copies of the original interactives' do
      let(:hidden_image)    { FactoryBot.create(:image_interactive, is_hidden: true)}
      let(:hidden_mw)       { FactoryBot.create(:mw_interactive, is_hidden: true)}
      let(:hidden_video)    { FactoryBot.create(:video_interactive, is_hidden: true)}
      let(:dupe)            { page.duplicate.reload}
      before(:each) do
        page.add_interactive hidden_image
        page.add_interactive hidden_mw
        page.add_interactive hidden_video
        page.reload
      end
      it "should have the same number of interactives as the original" do
        expect(dupe.interactives.length).to be(page.interactives.length)
      end

      it "should have copies of interactives with the same visibility" do
        page.interactives.each_with_index do |original,i|
          interactive_copy = dupe.interactives[i]
          expect(original.is_hidden?).to eq interactive_copy.is_hidden?
        end
      end
    end

    describe 'has copies of the original embeddables' do
      let(:hidden_text)    { FactoryBot.create(:xhtml, is_hidden: true)}
      let(:hidden_labbook) { FactoryBot.create(:labbook, is_hidden: true)}
      let(:dupe)           { page.duplicate.reload}
      before(:each) do
        page.add_embeddable hidden_labbook
        page.add_embeddable hidden_text
      end

      it "should have the same number of embeddables" do
        expect(dupe.sections[0].embeddables.length).to be(page.sections[0].embeddables.length)
      end

      it "should have embeddables of the same visibility as the original" do
        page.sections[0].embeddables.each_with_index do |original,i|
          copy_emb = dupe.sections[0].embeddables[i]
          expect(original.is_hidden?).to eq copy_emb.is_hidden?
        end
      end
    end


    describe "copying a labbook with a reference to an interactive" do
      before(:each) do
        page.add_embeddable labbook
        page.reload
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

    describe "linked interactives linked once" do
      before(:each) do
        page.add_interactive mw_1
        page.add_interactive mw_2
        page.reload
      end

      let(:linked_mw_1)  { FactoryBot.create(:mw_interactive) }
      let(:linked_mw_2)  { FactoryBot.create(:mw_interactive) }
      let(:mw_1)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_1) }
      let(:mw_2)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_2) }

      let(:dupe)         { page.duplicate }

      it "should create a duplicate of the linked interactive" do
        expect(page.interactives[0].linked_interactive.url).to eql (dupe.interactives[0].linked_interactive.url)
        expect(page.interactives[1].linked_interactive.url).to eql (dupe.interactives[1].linked_interactive.url)

        expect(page.interactives[0].linked_interactive.url).not_to eql (dupe.interactives[1].linked_interactive.url)
        expect(page.interactives[1].linked_interactive.url).not_to eql (dupe.interactives[0].linked_interactive.url)
      end
    end

    describe "linked interactives linked multiple times" do
      before(:each) do
        page.add_interactive mw_1
        page.add_interactive mw_2
        page.add_interactive mw_3
        page.add_interactive mw_4
        page.add_interactive mw_5
        page.add_interactive mw_6
        page.reload
      end

      let(:linked_mw_1)  { FactoryBot.create(:mw_interactive) }
      let(:linked_mw_2)  { FactoryBot.create(:mw_interactive) }
      let(:mw_1)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_1) }
      let(:mw_2)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_1) }
      let(:mw_3)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_1) }
      let(:mw_4)         { FactoryBot.create(:mw_interactive) }
      let(:mw_5)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_2) }
      let(:mw_6)         { FactoryBot.create(:mw_interactive, linked_interactive: linked_mw_2) }

      let(:dupe)         { page.duplicate }

      it "should create a single duplicate of the linked interactive" do
        expect(page.interactives[0].linked_interactive.url).to eql (dupe.interactives[0].linked_interactive.url)
        expect(dupe.interactives[0].linked_interactive).to eql (dupe.interactives[1].linked_interactive)
        expect(dupe.interactives[0].linked_interactive).to eql (dupe.interactives[2].linked_interactive)

        expect(dupe.interactives[3].linked_interactive).to be_nil

        expect(page.interactives[4].linked_interactive.url).to eql (dupe.interactives[4].linked_interactive.url)
        expect(dupe.interactives[4].linked_interactive).not_to eql (dupe.interactives[2].linked_interactive)
        expect(dupe.interactives[4].linked_interactive).to eql (dupe.interactives[5].linked_interactive)
      end
    end

    describe "interactives linked to each other" do
      let(:int_1) { FactoryBot.create(:mw_interactive) }
      let(:int_2) { FactoryBot.create(:managed_interactive) }
      let(:int_3) { FactoryBot.create(:mw_interactive) }
      let(:int_4) { FactoryBot.create(:managed_interactive) }
      let(:dupe)  { page.duplicate }

      before(:each) do
        page.add_interactive int_1
        page.add_interactive int_2
        page.add_interactive int_3
        page.add_interactive int_4
        page.reload

        add_linked_interactive(int_1, int_2, "one")
        add_linked_interactive(int_1, int_3, "two")
        add_linked_interactive(int_4, int_1, "three")
      end

      it "should link the interactives" do
        dup_int_1, dup_int_2, dup_int_3, dup_int_4 = dupe.embeddables.last(4)
        dup_int_1_linked_items = dup_int_1.primary_linked_items
        expect(dup_int_1_linked_items.length).to be 2
        expect(dup_int_1_linked_items[0].secondary.embeddable).to eq dup_int_2
        expect(dup_int_1_linked_items[1].secondary.embeddable).to eq dup_int_3
        expect(dup_int_1_linked_items[0].label).to eq "one"
        expect(dup_int_1_linked_items[1].label).to eq "two"

        expect(dup_int_2.page_item.primary_linked_items.length).to be 0
        expect(dup_int_3.page_item.primary_linked_items.length).to be 0

        dup_int_4_linked_items = dup_int_4.primary_linked_items
        expect(dup_int_4.page_item.primary_linked_items.length).to be 1
        expect(dup_int_4_linked_items[0].secondary.embeddable).to eq dup_int_1
        expect(dup_int_4_linked_items[0].label).to eq "three"
      end
    end
  end

  ## TODO: Test that 'additional_sections' imports from json.
  describe '#import' do
    let(:example_json_file) { 'valid_lightweight_activity_import_v2' }
    let(:activity_json) do
      JSON.parse(File.read(
        Rails.root +
        "spec/import_examples/#{example_json_file}.json"),
        symbolize_names: true)
    end

    describe "from a valid_lightweight_activity" do
      let(:example_json_file) { 'valid_lightweight_activity_import_v2' }
      it 'imports page from json' do
        activity_json[:pages].each do |p|
          page = InteractivePage.import(p)
          expect(page).to be_a(InteractivePage)
          expect(p[:name]).to eq(page.name)
          expect(p[:sidebar_title]).to eq(page.sidebar_title)
          expect(p[:position]).to be(page.position)
        end
      end
    end
  end

  describe 'InteractivePage#register_additional_section' do
    before(:all) do
      InteractivePage.register_additional_section({name:        'test_section',
                                                   dir:         'dir',
                                                   label:       'label',
                                                   show_method: 'show_test_section'})
    end
    it 'should add new methods (show_<secion_name_)' do
      expect(page).not_to respond_to(:show_unexisting_section)
      expect(page).to respond_to(:show_test_section)
      expect(page).to respond_to(:show_test_section=)
    end
  end

  describe '#reportable_items' do
    let(:non_reportable_interactive) {
      FactoryBot.create(:mw_interactive, enable_learner_state: false, has_report_url: false)
    }
    let(:reportable_interactive) {
      FactoryBot.create(:mw_interactive, enable_learner_state: true, has_report_url: false)
    }
    let(:reportable_interactive2) {
      FactoryBot.create(:mw_interactive, enable_learner_state: true, has_report_url: true)
    }
    let(:video_interactive) { FactoryBot.create(:video_interactive) }
    let(:image_interactive) { FactoryBot.create(:image_interactive) }

    let(:or_question) { FactoryBot.create(:or_embeddable) }
    let(:im_question) { FactoryBot.create(:image_question, prompt: "draw your answer") }
    let(:mc_question) { FactoryBot.create(:mc_with_choices) }
    let(:labbook_question) { FactoryBot.create(:labbook, interactive: reportable_interactive) }
    let(:xhtml) { FactoryBot.create(:xhtml) }

    before(:each) do
      interactives.each{|interactive|
        page.add_interactive interactive
      }
      embeddables.each{|embeddable|
        page.add_embeddable embeddable
      }
      page.reload
    end

    subject { page.reportable_items }

    context 'with a basic set of items' do
      let(:interactives) { [reportable_interactive, reportable_interactive2] }
      let(:embeddables) { [or_question, im_question, mc_question] }
      it { is_expected.to eql(embeddables + interactives) }
    end

    context 'with every possible interactive and embeddable type' do
      let(:interactives) { [reportable_interactive, reportable_interactive2, video_interactive, image_interactive]}
      let(:embeddables) { [or_question, im_question, mc_question, labbook_question, xhtml]}
      it 'returns just those that are reportable' do
        expect(page.reportable_items.length).to eql(6)
      end
    end

    context 'with a non reportable interactive' do
      let(:interactives) { [non_reportable_interactive] }
      let(:embeddables) { [] }
      it 'does not return it' do
        expect(subject.length).to eql(0)
      end
    end

    context 'when the reportable interactive is hidden' do
      let(:reportable_interactive) {
        FactoryBot.create(:mw_interactive,
          enable_learner_state: true,
          has_report_url: true,
          is_hidden: true)
      }
      let(:interactives) { [reportable_interactive] }
      let(:embeddables) { [] }
      it 'does not return it' do
        expect(subject.length).to eql(0)
      end
    end

    context 'when the embeddable open reponse is hidden' do
      let(:or_question) { FactoryBot.create(:or_embeddable, is_hidden: true) }
      let(:interactives) { [] }
      let(:embeddables) { [or_question] }
      it 'does not return it' do
        expect(subject.length).to eql(0)
      end
    end

    # TODO: Add tests for Labbooks in various states of being hidden or not-hidden
  end

  describe "A completion page" do
    let(:page)       { FactoryBot.create(:page, is_completion: true) }

    describe "#to_hash" do
      it "should respect the _is_completion property" do
        expect(page.to_hash).to include({is_completion: true})
      end
    end

    describe "#duplicate" do
      it "should respect the _is_completion property" do
        copy = page.duplicate
        expect(copy.is_completion).to be_truthy
      end
    end
  end

  describe "#add_embeddable" do
    let(:page)        { FactoryBot.create(:page) }
    let(:embeddables) { FactoryBot.create_list(:or_embeddable, 5)}

    describe "without specifying a section" do
      it "should put everything in the default (assessment block) section" do
        embeddables.each { |e| page.add_embeddable(e) }
        expect(page.visible_embeddables.length).to eq(5)
        page.visible_embeddables.each do |e|
          expect(e.page_section).to eq(Section::DEFAULT_SECTION_TITLE)
        end
        expect(page.sections.length).to eq(1)
      end
    end

    describe "specifying the section to add to" do
      it "should put everything in the same section" do
        s = page.sections.create({title: "some random section"})
        embeddables.each { |e| page.add_embeddable(e, 1, s) }
        page.visible_embeddables.each do |e|
          expect(e.page_section).to eq(s.title)
        end
        expect(page.sections.length).to eq(1)
      end
    end

    describe "specifying the section to add to by name" do
      it "should put everything in the same section" do
        s = page.sections.create({title: "some random section"})
        embeddables.each { |e| page.add_embeddable(e, 1, s.title) }
        page.visible_embeddables.each do |e|
          expect(e.page_section).to eq(s.title)
        end
        expect(page.sections.length).to eq(1)
      end
    end

    describe "specifying five unique sections" do
      it "should put everything in its own section" do
        embeddables.each_with_index do |e, i|
          s = page.sections.create({title: "section #{i}"})
          page.add_embeddable(e, 1, s.title)
        end
        expect(page.sections.length).to eq(5)
        expect(page.sections.map(&:title)).to include("section 0")
        expect(page.sections.map(&:title)).to include("section 1")
        expect(page.sections.map(&:title)).to include("section 2")
        expect(page.sections.map(&:title)).to include("section 3")
        expect(page.sections.map(&:title)).to include("section 4")
      end
    end
  end
end
