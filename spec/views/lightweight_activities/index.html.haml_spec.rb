require 'spec_helper'

def have_community_listing_section
  have_css "#community_listing_heading"
end

def have_community_item_count(n)
  have_css "li.community", :count=> n
end

def have_official_listing_section
  have_css "#official_listing_heading"
end

def have_official_listing_count(n)
  have_css "li.official", :count=> n
end

def fake_activity(official=false, is_public=true)
  return mock_model(LightweightActivity,
    name: "name",
    description: "description",
    publication_status: is_public ? 'published' : 'draft',
    user: user,
    updated_at: Date.new,
    created_at: Date.new,
    changed_by: user,
    is_official: official
  )
end

def community_activity
  fake_activity(false)
end

def official_activity
  fake_activity(true)
end


describe "lightweight_activities/index" do

#  let(:activity)  { stub_model(LightweightActivity, :id => 1) }
  let(:user)       { stub_model(User, :is_admin => false)      }
  let(:activities) { [] }

  before(:each) do
    view.stub!(:current_user).and_return(user)
    view.stub!(:can?).and_return(true)     # stub-out can-can features
    view.stub!(:cannot?).and_return(false) # stub-out can-can features
    assign(:activities, activities)
  end

  describe "with official activities" do
    let(:activities){ 5.times.map{ official_activity() } }

    it "should not have a community section" do
      render
      rendered.should_not have_community_listing_section
      rendered.should have_community_item_count(0)
    end

    it "should have an official section" do
      render
      rendered.should have_official_listing_section
      rendered.should have_official_listing_count(5)
    end
  end

  describe "with only non-official activities" do
    let(:activities){ 5.times.map{ community_activity() } }

    it "should have community section" do
      render
      rendered.should have_community_listing_section
      rendered.should have_community_item_count(5)
    end

    it "should not have an official section" do
      render
      rendered.should_not have_official_listing_section
      rendered.should have_official_listing_count(0)
    end
  end

  describe "and non-official activities" do
    let(:offical)    { 5.times.map{ official_activity()  }}
    let(:community)  { 3.times.map{ community_activity() }}
    let(:activities) { offical + community                }

    it "should have a community section" do
      render
      rendered.should have_community_listing_section
      rendered.should have_community_item_count(3)
    end

    it "should have an official section" do
      render
      rendered.should have_official_listing_section
      rendered.should have_official_listing_count(5)
    end
  end

  it 'provides a link to create a new Lightweight Activity on the index page' do
    render
    rendered.should match /<a[^>]+href="\/activities\/new"[^>]*>/
  end

  describe 'with all activities' do
    let(:activities) { 2.times.map{ official_activity() } }

    it 'provides a list of authored Lightweight Activities with edit and run links on the index page' do
      render
      rendered.should match /<a[^>]+href="\/activities\/[\d]+\/edit"[^>]*>[\s]*Edit[\s]*<\/a>/
      rendered.should match /<a[^>]+href="\/activities\/[\d]+"[^>]*>[\s]*Run[\s]*<\/a>/
    end
  end
end
