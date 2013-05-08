require 'spec_helper'

describe LightweightActivity do
  let (:valid) { FactoryGirl.build(:activity) }
  let (:activity) { FactoryGirl.create(:activity) }
  let (:author) { FactoryGirl.create(:author) }

  it 'should have valid attributes' do
    activity.name.should_not be_blank
    activity.publication_status.should == "private"
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
      expected = { name: activity.name, related: activity.related, description: activity.description }
      activity.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'creates a new LightweightActivity with attributes from the original' do
      # We won't check name here in case the generated name is long enough to trigger truncation
      activity.duplicate.should be_a_new(LightweightActivity).with( related: activity.related, description: activity.description )
    end

    it 'has pages in the same order as the source activity' do
      2.times do
        activity.pages << FactoryGirl.create(:page)
      end
      duplicate = activity.duplicate
      duplicate.pages.each_with_index do |p, i|
        duplicate.pages[i].name.should == p.name
        duplicate.pages[i].position.should be(p.position)
        duplicate.pages[i].last?.should be(p.last?)
      end
    end
  end
end
