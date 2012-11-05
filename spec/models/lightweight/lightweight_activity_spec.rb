require 'spec_helper'

describe Lightweight::LightweightActivity do
  before :each do
    @valid = {
      :name => "Activity"
    }
    @activity = Lightweight::LightweightActivity.create!(@valid)
  end

  it 'should have valid attributes' do
    @activity.name.should == "Activity"
  end

  it 'should have pages' do
    [3,1,2].each do |i|
      page = Lightweight::InteractivePage.create!(:name => "page #{i}", :text => "some text #{i}", :position => i)
      @activity.pages << page
    end
    @activity.reload

    @activity.pages.size.should == 3
  end

  it 'should have interactives in the correct order' do
    [3,1,2].each do |i|
      page = Lightweight::InteractivePage.create!(:name => "page #{i}", :text => "some text #{i}", :position => i)
      @activity.pages << page
    end
    @activity.reload

    @activity.pages.first.text.should == "some text 1"
    @activity.pages.last.name.should == "page 3"
  end
end
