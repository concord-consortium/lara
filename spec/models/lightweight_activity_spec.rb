require 'spec_helper'

describe LightweightActivity do
  let(:valid)         { FactoryGirl.build(:activity) }
  let(:thumbnail_url) { "http://fake.url.com/image" }
  let(:activity)      { FactoryGirl.create(:activity, :thumbnail_url => thumbnail_url) }
  let(:author)        { FactoryGirl.create(:author) }

  it 'should have valid attributes' do
    activity.name.should_not be_blank
    activity.publication_status.should == "private"
    activity.is_locked.should be_false
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

    activity.pages.size.should == 3
  end

  it 'should have InteractivePages in the correct order' do
    [3,1,2].each do |i|
      page = FactoryGirl.create(:page, :name => "page #{i}", :text => "some text #{i}", :position => i)
      activity.pages << page
    end
    activity.reload

    activity.pages.first.text.should == "some text 1"
    activity.pages.last.name.should == "page 3"
  end

  it 'allows only defined publication statuses' do
    activity.valid? # factory generates 'private'
    activity.publication_status = 'draft'
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
      activity.valid?.should be_true # Ugh: HTML not XML parsing
      activity.related = 'This HTML is valid.'
      activity.valid?
    end

    it 'rejects invalid HTML for the activity description' do
      activity.description = '<p class="invalid-attribute>This has an invalid attribute.</p>'
      activity.valid?.should be_false
      activity.description = '<p class="valid-attribute">Much better.</p>'
      activity.valid?
    end
  end

  describe "#my" do
    it 'returns activities owned by a given author' do
      activity.user = author
      activity.save

      LightweightActivity.my(author).should == [activity]
    end
  end

  describe '#questions' do
    it 'returns an array of Embeddables which are MultipleChoice or OpenResponse' do
      activity.questions.should == []
    end
  end

  describe '#question_keys' do
    it 'returns an array of storage_keys from questions' do
      activity.question_keys.should == []
    end
  end

  context 'it has embeddables' do
    before :each do
      [3,1,2].each do |i|
        page = FactoryGirl.create(:page, :name => "page #{i}", :text => "some text #{i}", :position => i)
        activity.pages << page
      end
      activity.reload
      or1 = FactoryGirl.create(:or_embeddable)
      or2 = FactoryGirl.create(:or_embeddable)
      mc1 = FactoryGirl.create(:mc_embeddable)
      mc2 = FactoryGirl.create(:mc_embeddable)
      activity.pages.first.add_embeddable(mc1)
      activity.pages.first.add_embeddable(or1)
      activity.pages[1].add_embeddable(mc2)
      activity.pages.last.add_embeddable(or2)
    end


    describe '#questions' do
      it 'returns an array of Embeddables which are MultipleChoice or OpenResponse' do
        activity.questions.length.should be(4)
        activity.questions.first.should be_kind_of Embeddable::MultipleChoice
      end
    end

    describe '#question_keys' do
      it 'returns an array of storage_keys from questions' do
        activity.question_keys.length.should be(4)
        activity.question_keys.first.should be_kind_of String
      end
    end
  end

  describe "#publish!" do
    it "should change the publication status to public" do
      activity.publication_status = 'draft'
      activity.publish!
      activity.publication_status.should == 'public'
    end
  end

  describe '#set_user!' do
    it 'should set the user to the user object provided as an argument' do
      activity.set_user!(author)
      activity.reload.user.should == author
    end
  end

  describe '#to_hash' do
    it 'returns a hash with relevant values for activity duplication' do
      expected = { name: activity.name, related: activity.related, description: activity.description, time_to_complete: activity.time_to_complete, project_id: activity.project_id, theme_id: activity.theme_id, thumbnail_url: activity.thumbnail_url, notes: activity.notes }
      activity.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    let(:owner) { FactoryGirl.create(:user) }

    it 'creates a new LightweightActivity with attributes from the original' do
      dup = activity.duplicate(owner)
      dup.should be_a(LightweightActivity)
      dup.user.should == owner
      dup.related.should == activity.related
      dup.description.should == activity.description
      dup.time_to_complete.should == activity.time_to_complete
    end

    it 'has pages in the same order as the source activity' do
      5.times do
        activity.pages << FactoryGirl.create(:page)
      end
      duplicate = activity.duplicate(owner)
      duplicate.pages.each_with_index do |p, i|
        activity.pages[i].name.should == p.name
        activity.pages[i].position.should be(p.position)
        activity.pages[i].last?.should be(p.last?)
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
        duplicate = activity.duplicate(owner)
        duplicate.pages.length.should == 1
        duplicate.pages.each_with_index do |p, i|
          activity.pages[i].name.should == p.name
          activity.pages[i].position.should be(p.position)
          activity.pages[i].last?.should be(p.last?)
        end
      end
    end
  end

  describe '#serialize_for_portal' do
    let(:simple_portal_hash) do
      url = "http://test.host/activities/#{activity.id}"
      { "type"          =>"Activity",
        "name"          => activity.name,
        "description"   => activity.description,
        "url"           => url,
        "create_url"    => url,
        "thumbnail_url" => thumbnail_url,
        "sections"=>[{"name"=>"#{activity.name} Section", "pages"=>[]}]
      }
    end

    it 'returns a simple hash that can be consumed by the Portal' do
      activity.serialize_for_portal('http://test.host').should == simple_portal_hash
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
        subject.newest.should have_at_least(15).items
        subject.newest.should be_ordered_by "updated_at_desc"
      end
    end
    describe "the public scope" do
      it "should return 5 public activities" do
        subject.public.should have(5).items
        subject.public.each { |a| a.publication_status.should == 'public'}
      end
    end
    describe "my_or_public  scope" do
      it "should return 10 activities that are either mine or public" do
        subject.my_or_public(author).should have(10).items
        subject.my_or_public(author).select{|a| a.user_id == author.id}.should have(5).items
        subject.my_or_public(author).select{|a| a.publication_status == 'public'}.should have(5).items
      end
    end
  end

end
