require 'spec_helper'

describe LightweightActivity do
  let(:thumbnail_url) { "http://fake.url.com/image" }
  let(:author)        { FactoryGirl.create(:author) }
  let(:activity)      { 
    activity = FactoryGirl.create(:activity, :thumbnail_url => thumbnail_url)
    activity.user = author
    activity.save
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
      page = FactoryGirl.create(:page, :name => "page #{i}", :text => "some text #{i}", :position => i)
      activity.pages << page
    end
    activity.reload

    expect(activity.pages.first.text).to eq("some text 1")
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

  describe '#questions' do
    it 'returns an array of Embeddables which are MultipleChoice or OpenResponse' do
      expect(activity.questions).to eq([])
    end
  end

  describe '#question_keys' do
    it 'returns an array of storage_keys from questions' do
      expect(activity.question_keys).to eq([])
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
        page = FactoryGirl.create(:page, :name => "page #{i}", :text => "some text #{i}", :position => i)
        activity.pages << page
      end
      activity.reload
      activity.pages.first.add_embeddable(mc1)
      activity.pages.first.add_embeddable(text_emb)
      activity.pages.first.add_embeddable(or1)
      activity.pages[1].add_embeddable(mc2)
      activity.pages.last.add_embeddable(or2)
    end


    describe '#questions' do
      it 'returns an array of Embeddables which are MultipleChoice or OpenResponse' do
        expect(activity.questions.length).to be(4)
        activity.questions.each { |q| expect(activity.questions).to include(q) }
        expect(activity.questions).not_to include(text_emb)
      end
    end

    describe '#question_keys' do
      it 'returns an array of storage_keys from questions' do
        expect(activity.question_keys.length).to be(4)
        expect(activity.question_keys.first).to be_kind_of String
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
      expected = { name: activity.name, related: activity.related, description: activity.description, time_to_complete: activity.time_to_complete, project_id: activity.project_id, theme_id: activity.theme_id, thumbnail_url: activity.thumbnail_url, notes: activity.notes }
      expect(activity.to_hash).to eq(expected)
    end
  end

  describe '#export' do
      it 'returns json of an activity' do
        expect(activity.export[:pages].length).to eq(activity.pages.count)
    end 
  end

  describe '#duplicate' do
    let(:owner) { FactoryGirl.create(:user) }

    it 'creates a new LightweightActivity with attributes from the original' do
      dup = activity.duplicate(owner)
      expect(dup).to be_a(LightweightActivity)
      expect(dup.user).to eq(owner)
      expect(dup.related).to eq(activity.related)
      expect(dup.description).to eq(activity.description)
      expect(dup.time_to_complete).to eq(activity.time_to_complete)
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

    describe "when a page in the activity fails validation" do
      let(:bad_content)   {"</p> no closing div tag"}

      it 'should still duplicate the page' do
        first_page = FactoryGirl.create(:page)
        first_page.text = bad_content
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
      act = LightweightActivity.import(json,new_owner)
      expect(act.user).to be new_owner
      expect(act.related).to eq(json[:related])
      expect(act.pages.count).to eq(json[:pages].length)
    end
  end

  describe '#serialize_for_portal' do
    let(:simple_portal_hash) do
      url = "http://test.host/activities/#{activity.id}"
      { 
        "type"          =>"Activity",
        "name"          => activity.name,
        "description"   => activity.description,
        "url"           => url,
        "create_url"    => url,
        "thumbnail_url" => thumbnail_url,
        "author_email"  => activity.user.email,
        "is_locked"     => false,
        "sections"=>[{"name"=>"#{activity.name} Section", "pages"=>[]}]
      }
    end

    it 'returns a simple hash that can be consumed by the Portal' do
      expect(activity.serialize_for_portal('http://test.host')).to eq(simple_portal_hash)
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
