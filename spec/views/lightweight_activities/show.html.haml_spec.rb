require 'spec_helper'

describe 'lightweight_activities/show' do
  # Stub what we need to render the page
  let (:page1) { stub_model(InteractivePage, :id => 1, :name => Faker::Lorem.sentence(1)[0..20]) }
  let (:page2) { stub_model(InteractivePage, :id => 2, :name => Faker::Lorem.sentence(1)[0..20]) }
  let (:activity) { stub_model(LightweightActivity, :id => 1, :name => Faker::Lorem.sentence(2)[0..49], :description => Faker::Lorem.sentences(3).join(" "), :pages => [page1, page2]) }
  
  # Assigns
  before(:each) do
    assign(:activity, activity)
    assign(:pages, [page1, page2])
  end

  it 'shows the activity title' do
    render
    rendered.should match /#{activity.name}/
  end

  it 'shows the activity description' do
    render
    rendered.should match /#{activity.description}/
  end

  it 'has numbered list of pages with titles' do
    render
    rendered.should have_css '.intro-mod ol li', :count => activity.pages.length
    rendered.should match /#{page1.name}/
    rendered.should match /#{page2.name}/
  end

  it 'has a begin-activity button' do
    render
    rendered.should have_css 'a div.submit input.button[type=submit]'
  end
end