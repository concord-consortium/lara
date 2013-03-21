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
end
