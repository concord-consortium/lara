require 'spec_helper'

describe LightweightActivity do
  before :each do
    @valid = {
      :name => "Activity"
    }
    @activity = LightweightActivity.create!(@valid)
  end

  it 'should have valid attributes' do
    @activity.name.should == "Activity"
    @activity.publication_status.should == "draft"
  end

  it 'should have pages' do
    [3,1,2].each do |i|
      page = InteractivePage.create!(:name => "page #{i}", :text => "some text #{i}", :position => i)
      @activity.pages << page
    end
    @activity.reload

    @activity.pages.size.should == 3
  end

  it 'should have InteractivePages in the correct order' do
    [3,1,2].each do |i|
      page = InteractivePage.create!(:name => "page #{i}", :text => "some text #{i}", :position => i)
      @activity.pages << page
    end
    @activity.reload

    @activity.pages.first.text.should == "some text 1"
    @activity.pages.last.name.should == "page 3"
  end

  it 'allows only defined publication statuses' do
    @activity.valid? # default publication_status: 'draft'
    @activity.publication_status = 'private'
    @activity.valid?
    @activity.publication_status = 'public'
    @activity.valid?
    @activity.publication_status = 'archive'
    @activity.valid?
    @activity.publication_status = 'invalid'
    !@activity.valid?
  end
end
