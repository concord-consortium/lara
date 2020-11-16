require 'spec_helper'

describe LightweightActivity do
  let(:thumbnail_url) { "http://fake.url.com/image" }
  let(:author)        { FactoryGirl.create(:author) }
  let(:act_opts)      { {thumbnail_url: thumbnail_url} }
  let(:activity)      {
    activity = FactoryGirl.create(:activity, act_opts)
    activity.user = author
    activity.save
    activity.theme = FactoryGirl.create(:theme)
    activity
  }
  let(:valid)         {
    activity = FactoryGirl.build(:activity)
    activity.user = author
    activity.save
    activity
  }

  it 'should have valid attributes' do
    expect(activity.name).not_to be_blank
    expect(activity.publication_status).to eq("hidden")
    expect(activity.is_locked).to be_falsey
  end

  it 'should not allow long names' do
    # They break layouts.
    activity.name = "Renamed activity with a really, really, long name, seriously this sucker is so long you might run out of air before you can pronounce the period which comes at the end."
    !activity.valid?
  end

  it 'should have pages' do
    [3,1,2].each do |i|
      page = FactoryGirl.create(:page)
      activity.pages << page
    end
    activity.reload

    expect(activity.pages.size).to eq(3)
  end

  it 'should have InteractivePages in the correct order' do
    [3,1,2].each do |i|
      page = FactoryGirl.create(:page, :name => "page #{i}", :position => i)
      activity.pages << page
    end
    activity.reload

    expect(activity.pages.last.name).to eq("page 3")
  end

  it 'allows only defined publication statuses' do
    activity.valid? # factory generates 'hidden'
    activity.publication_status = 'private'
    activity.valid?
    activity.publication_status = 'public'
    activity.valid?
    activity.publication_status = 'archive'
    activity.valid?
    activity.publication_status = 'invalid'
    !activity.valid?
  end

  describe 'validation of HTML blocks' do
    it 'rejects invalid HTML for related text' do
      activity.related = '<p>This HTML is invalid.<p>Tag soup.</p>'
      expect(activity.valid?).to be_truthy # Ugh: HTML not XML parsing
      activity.related = 'This HTML is valid.'
      activity.valid?
    end

    it 'rejects invalid HTML for the activity description' do
      activity.description = '<p class="invalid-attribute>This has an invalid attribute.</p>'
      expect(activity.valid?).to be_falsey
      activity.description = '<p class="valid-attribute">Much better.</p>'
      activity.valid?
    end
  end

  describe "#my" do
    it 'returns activities owned by a given author' do
      activity.user = author
      activity.save

      expect(LightweightActivity.my(author)).to eq([activity])
    end
  end

  describe '#reportable_items' do
    let(:page1) { FactoryGirl.create(:interactive_page_with_or, position: 1) }
    let(:page2) { FactoryGirl.create(:interactive_page_with_or, position: 2) }
    let(:reportable_interactive) {
      FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: true)
    }
    before(:each) do
      page2.add_interactive reportable_interactive
      activity.pages << page1
      activity.pages << page2
      activity.save
      activity.reload
    end

    it 'returns an array of embeddables and reportable interactives' do
      expect(activity.reportable_items.length).to eql(3)
      expect(activity.reportable_items).to eql(
        [page1.embeddables[0], page2.embeddables[0], reportable_interactive])
    end

    context 'when some pages are hidden' do
      let (:page2) { FactoryGirl.create(:interactive_page_with_or, is_hidden: true, position: 2) }

      it 'doesnt report on items on the hidden page' do
        expect(activity.pages[1].is_hidden).to eq true
        expect(activity.reportable_items).not_to include reportable_interactive
        expect(activity.reportable_items.length).to eql(1)
        expect(activity.reportable_items).to eql(page1.embeddables)
      end
    end
  end

  context 'it has embeddables' do
    let(:or1)       { FactoryGirl.create(:or_embeddable) }
    let(:or2)       { FactoryGirl.create(:or_embeddable) }
    let(:mc1)       { FactoryGirl.create(:mc_embeddable) }
    let(:mc2)       { FactoryGirl.create(:mc_embeddable) }
    let(:text_emb)  { FactoryGirl.create(:xhtml)         }
    let(:questions) { [ or1, or2, mc1, mc2]              }

    before :each do
      [3,1,2].each do |i|
        page = FactoryGirl.create(:page, :name => "page #{i}", :position => i)
        activity.pages << page
      end
      activity.reload
      activity.pages.first.add_embeddable(mc1)
      activity.pages.first.add_embeddable(text_emb)
      activity.pages.first.add_embeddable(or1)
      activity.pages[1].add_embeddable(mc2)
      activity.pages.last.add_embeddable(or2)
    end


    describe '#reportable_items' do
      it 'returns an array of Embeddables which are MultipleChoice or OpenResponse' do
        expect(activity.reportable_items.length).to be(4)
        activity.reportable_items.each { |q| expect(activity.reportable_items).to include(q) }
        expect(activity.reportable_items).not_to include(text_emb)
      end
    end

  end

  describe "#publish!" do
    it "should change the publication status to public" do
      activity.publication_status = 'private'
      activity.publish!
      expect(activity.publication_status).to eq('public')
    end
  end

  describe '#set_user!' do
    it 'should set the user to the user object provided as an argument' do
      activity.set_user!(author)
      expect(activity.reload.user).to eq(author)
    end
  end

  describe '#to_hash' do
    it 'returns a hash with relevant values for activity duplication' do
      expected = {
        name: activity.name,
        related: activity.related,
        publication_status: activity.publication_status,
        student_report_enabled: true,
        show_submit_button: true,
        description: activity.description,
        time_to_complete: activity.time_to_complete,
        project_id: activity.project_id,
        theme_id: activity.theme_id,
        thumbnail_url: activity.thumbnail_url,
        notes: activity.notes,
        layout: activity.layout,
        editor_mode: activity.editor_mode,
        activity_player_only: false }
      expect(activity.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    let(:export) { activity.export }
    describe "the activity json" do
      it 'includes the activity pages' do
        expect(export[:pages].length).to eq(activity.pages.count)
      end
      it 'includes the plugins' do
        expect(export[:plugins].length).to eq(activity.plugins.count)
      end
    end
  end

  describe '#duplicate' do
    let(:owner)     { FactoryGirl.create(:user) }
    let(:edit_mode) { LightweightActivity::STANDARD_EDITOR_MODE }
    let(:layout)    { LightweightActivity::LAYOUT_MULTI_PAGE    }

    let(:approved_script) { FactoryGirl.create(:approved_script) }
    let(:plugins) do
      FactoryGirl.create_list(:plugin, 2, approved_script: approved_script)
    end
    before :each do
      activity.layout = layout
      activity.editor_mode = edit_mode
      plugins.each { |p| activity.plugins.push(p) }
    end

    it 'creates a new LightweightActivity with attributes from the original' do
      dup = activity.duplicate(owner)
      expect(dup).to be_a(LightweightActivity)
      expect(dup.user).to eq(owner)
      expect(dup.related).to eq(activity.related)
      expect(dup.description).to eq(activity.description)
      expect(dup.time_to_complete).to eq(activity.time_to_complete)
      expect(dup.layout).to eq(activity.layout)
      expect(dup.editor_mode).to eq(activity.editor_mode)
      expect(dup.name).to match /^Copy of #{activity.name[0..30]}/
    end

    describe 'describe copying the activities plugins' do
      let(:dup) { activity.duplicate(owner) }
      describe "when the approved_script exists" do
        it "will copy all the plugins" do
          dup.plugins.each do |p|
            expect(plugins.map(&:name)).to include(p.name)
            expect(p.approved_script).to eql(approved_script)
            expect(p).not_to eql(plugins[0])
            expect(p).not_to eql(plugins[1])
          end
        end
      end
      describe "when the approved_script does not exist" do
        before(:each) do
          expect(ApprovedScript).to receive(:find_by_label).at_least(:once).and_return(nil)
        end
        it "will copy the plugins even without approved_script set" do
          dup.plugins.each do |p|
            expect(p.plugin_scope).to eql(dup)
            expect(p.approved_script).to be_nil
          end
        end
      end
    end

    describe "an activity with an open response" do
      let(:prompt)        { "xyzzy" }
      let(:page)          { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
      let(:open_response) {FactoryGirl.create(:open_response, prompt:prompt) }
      before(:each) do
        page.add_embeddable(open_response)
        activity.pages << page
      end
      it "the duplicate should have a copy of the open response" do
        dup = activity.duplicate(owner)
        embeddable = dup.pages.first.embeddables.first
        expect(embeddable.prompt).to eq prompt
      end
      describe "when the embeddable is a tracked question" do
        let(:master_question)  { FactoryGirl.create(:open_response, prompt:prompt) }
        let(:question_tracker) { QuestionTracker.create(master_question:master_question ) }
        let(:open_response)    { question_tracker.new_question }
        before(:each) do
          question_tracker.add_question(open_response)
        end
        it "the duplicate open response should have a question_tracker" do
          dup = activity.duplicate(owner)
          embeddable = dup.pages.first.embeddables.first
          expect(embeddable.question_tracker).to_not be_nil
          expect(embeddable.prompt).to eq open_response.prompt
        end
      end
    end

   describe "an activity with an image interactive" do
      let(:prompt)        { "xyzzy" }
      let(:page)          { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
      let(:url)           { "http://foo.bar/kitten.jpg" }
      let(:interactive)   { FactoryGirl.create(:image_interactive, url:url) }
      before(:each) do
        page.add_interactive(interactive)
        page.reload
        activity.pages << page
      end
      it "the duplicate should have a copy of the interactive" do
        dup = activity.duplicate(owner)
        dup_int = dup.pages.first.interactives.first
        expect(dup_int.url).to eq url
      end
    end

    describe "for itsi activities" do
      let(:edit_mode) { LightweightActivity::ITSI_EDITOR_MODE   }
      let(:layout)    { LightweightActivity::LAYOUT_SINGLE_PAGE }

      it "should use the itsi edit mode, and single page layout" do
        dup = activity.duplicate(owner)
        expect(dup.layout).to eq LightweightActivity::LAYOUT_SINGLE_PAGE
        expect(dup.editor_mode).to eq LightweightActivity::ITSI_EDITOR_MODE
      end
    end

    it 'has pages in the same order as the source activity' do
      5.times do
        activity.pages << FactoryGirl.create(:page)
      end
      duplicate = activity.duplicate(owner)
      duplicate.pages.each_with_index do |p, i|
        expect(activity.pages[i].name).to eq(p.name)
        expect(activity.pages[i].position).to be(p.position)
        expect(activity.pages[i].last?).to be(p.last?)
      end
    end

    it 'has hidden pages that are hidden in the source' do
      3.times do |n|
        activity.pages << FactoryGirl.create(:page, is_hidden: true)
        activity.pages << FactoryGirl.create(:page, is_hidden: false)
      end
      duplicate = activity.duplicate(owner)
      hidden_count = 0
      visibile_count = 0
      duplicate.pages.each do |p|
        if p.is_hidden?
          hidden_count = hidden_count + 1
        else
          visibile_count = visibile_count + 1
        end
      end
      expect(hidden_count).to eq 3
      expect(visibile_count).to eq 3
    end

    describe "when a page in the activity fails validation" do
      let(:bad_content)   {"</p> no closing div tag"}

      it 'should still duplicate the page' do
        first_page = FactoryGirl.create(:page)
        first_page.sidebar = bad_content
        activity.pages << first_page
        activity.fix_page_positions
        activity.description = bad_content
        activity.save!(validate: false)
        expect(activity).not_to be_valid
        duplicate = activity.duplicate(owner)
        expect(duplicate.pages.length).to eq(1)
        duplicate.pages.each_with_index do |p, i|
          expect(activity.pages[i].name).to eq(p.name)
          expect(activity.pages[i].position).to be(p.position)
          expect(activity.pages[i].last?).to be(p.last?)
        end
      end
    end
  end

  describe '#import' do
    let(:new_owner) { FactoryGirl.create(:user) }

    it 'should return an activity' do
      json = JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json'), :symbolize_names => true)
      imported_activity_url = "http://foo.com/"
      act = LightweightActivity.import(json,new_owner,imported_activity_url)
      expect(act.user).to be new_owner
      expect(act.related).to eq(json[:related])
      expect(act.imported_activity_url).to eq(imported_activity_url)
      expect(act.pages.count).to eq(json[:pages].length)
    end
  end

  describe '#serialize_for_portal' do
    let(:simple_portal_hash) do
      url = "http://test.host/activities/#{activity.id}"
      author_url = "#{url}/edit"
      print_url = "#{url}/print_blank"
      {
        "source_type"   => "LARA",
        "type"          =>"Activity",
        "name"          => activity.name,
        "description"   => activity.description,
        "url"           => url,
        "create_url"    => url,
        "author_url"    => author_url,
        "print_url"     => print_url,
        "thumbnail_url"       => thumbnail_url,
        "author_email"        => activity.user.email,
        "student_report_enabled" => activity.student_report_enabled,
        "show_submit_button"  => true,
        "is_locked"           => false,
        "sections"            =>[{"name"=>"#{activity.name} Section", "pages"=>[]}],
        "append_auth_token"   => false,
        "tool_id"           => ""
      }
    end

    it 'returns a simple hash that can be consumed by the Portal' do
      expect(activity.serialize_for_portal('http://test.host')).to eq(simple_portal_hash)
    end

    describe 'pages section' do
      before(:each) do
        activity.pages << FactoryGirl.create(:page, name: 'page 1', position: 0)
        activity.pages << FactoryGirl.create(:page, name: 'page 2', position: 1)
        activity.pages << FactoryGirl.create(:page, name: 'hidden page', is_hidden: true, position: 2)
        activity.reload
      end

      it 'returns only visible pages' do
        pages = activity.serialize_for_portal('http://test.host')['sections'][0]['pages']
        expect(pages.length).to eql(2)
        expect(pages[0]['name']).to eql('page 1')
        expect(pages[0]['url']).to match /http:\/\/test.host\/pages\/\d+/
        expect(pages[1]['name']).to eql('page 2')
        expect(pages[1]['url']).to match /http:\/\/test.host\/pages\/\d+/
      end
    end

    describe 'pages section with hidden embeddables & reportable interactives' do
      let(:page1) { FactoryGirl.create(:interactive_page_with_or, name: 'page 1', position: 0) }
      let(:page2) { FactoryGirl.create(:interactive_page_with_hidden_or, name: 'page 2', position: 1) }
      let(:page3) { FactoryGirl.create(:interactive_page_with_or, name: 'page 3', position: 2) }
      let(:page4) { FactoryGirl.create(:interactive_page_with_or, name: 'page 4', position: 3) }

      let(:non_reportable_interactive) {
        FactoryGirl.create(:mw_interactive, enable_learner_state: false, has_report_url: false)
      }

      let(:reportable_interactive) {
        FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: true)
      }

      before(:each) do
        page3.add_interactive reportable_interactive
        page4.add_interactive non_reportable_interactive
        activity.pages << page1
        activity.pages << page2
        activity.pages << page3
        activity.pages << page4
        activity.reload
      end

      it 'returns only visible embeddables' do
        pages = activity.serialize_for_portal('http://test.host')['sections'][0]['pages']
        expect(pages.length).to eql(4)
        expect(pages[0]['name']).to eql('page 1')
        expect(pages[0]['elements'].length).to eql(1)
        expect(pages[1]['name']).to eql('page 2')
        expect(pages[1]['elements'].length).to eql(0)
        expect(pages[2]['elements'].length).to eql(2)
        expect(pages[3]['elements'].length).to eql(1)
      end
    end
  end

  describe '#serialize_for_report_service' do
    it 'returns a simple hash that can be consumed by the report service' do
      url = "http://test.host/activities/#{activity.id}"
      report_service_hash = {
        id: "activity_#{activity.id}",
        type: "activity",
        name: activity.name,
        url: url,
        children: [
          {
            id: "section_#{activity.id}",
            type: "section",
            name: "#{activity.name} Section",
            url: url,
            children: []
          }
        ]
      }
      expect(activity.serialize_for_report_service('http://test.host')).to eq(report_service_hash)
    end

    describe 'pages section' do
      before(:each) do
        activity.pages << FactoryGirl.create(:page, name: 'page 1', position: 0)
        activity.pages << FactoryGirl.create(:page, name: 'page 2', position: 1)
        activity.pages << FactoryGirl.create(:page, name: 'hidden page', is_hidden: true, position: 2)
        activity.reload
      end

      it 'returns only visible pages' do
        pages = activity.serialize_for_report_service('http://test.host')[:children][0][:children]
        expect(pages.length).to eql(2)
        expect(pages[0][:type]).to eql('page')
        expect(pages[0][:name]).to eql('page 1')
        expect(pages[0][:url]).to match /http:\/\/test.host\/pages\/\d+/
        expect(pages[1][:type]).to eql('page')
        expect(pages[1][:name]).to eql('page 2')
        expect(pages[1][:url]).to match /http:\/\/test.host\/pages\/\d+/
      end
    end

    describe 'pages section with hidden embeddables & reportable interactives' do
      let(:page1) { FactoryGirl.create(:interactive_page_with_or, name: 'page 1', position: 0) }
      let(:page2) { FactoryGirl.create(:interactive_page_with_hidden_or, name: 'page 2', position: 1) }
      let(:page3) { FactoryGirl.create(:interactive_page_with_or, name: 'page 3', position: 2) }
      let(:page4) { FactoryGirl.create(:interactive_page_with_or, name: 'page 4', position: 3) }

      let(:non_reportable_interactive) {
        FactoryGirl.create(:mw_interactive, enable_learner_state: false, has_report_url: false)
      }

      let(:reportable_interactive) {
        FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: true)
      }

      before(:each) do
        page3.add_interactive reportable_interactive
        page4.add_interactive non_reportable_interactive
        activity.pages << page1
        activity.pages << page2
        activity.pages << page3
        activity.pages << page4
        activity.reload
      end

      it 'returns only visible embeddables' do
        pages = activity.serialize_for_report_service('http://test.host')[:children][0][:children]
        expect(pages.length).to eql(4)
        expect(pages[0][:name]).to eql('page 1')
        expect(pages[0][:children].length).to eql(1)
        expect(pages[1][:name]).to eql('page 2')
        expect(pages[1][:children].length).to eql(0)
        expect(pages[2][:children].length).to eql(2)
        expect(pages[3][:children].length).to eql(1)
      end
    end
  end

  describe "named scopes" do
    subject   { LightweightActivity }
    before(:each) do
      # 5 private activities
      make_collection_with_rand_modication_time(:activity, 5)
      # 5 public activities
      make_collection_with_rand_modication_time(:public_activity, 5)
      # 5 of my activities
      make_collection_with_rand_modication_time(:activity, 5, {:user => author })
    end

    describe "the newest scope" do
      it "should return all items, the most recent items first" do
        expect(subject.newest.size).to be >= 15
        expect(subject.newest).to be_ordered_by "updated_at_desc"
      end
    end
    describe "the public scope" do
      it "should return 5 public activities" do
        expect(subject.public.size).to eq(5)
        subject.public.each { |a| expect(a.publication_status).to eq('public')}
      end
    end
    describe "my_or_public  scope" do
      it "should return 10 activities that are either mine or public" do
        expect(subject.my_or_public(author).size).to eq(10)
        expect(subject.my_or_public(author).select{|a| a.user_id == author.id}.size).to eq(5)
        expect(subject.my_or_public(author).select{|a| a.publication_status == 'public'}.size).to eq(5)
      end
    end
  end
end
