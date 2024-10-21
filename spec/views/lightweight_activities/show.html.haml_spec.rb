require 'spec_helper'

describe 'lightweight_activities/show' do
  # Stub what we need to render the page
  let (:page1) { stub_model(InteractivePage, :id => 1, :name => Faker::Lorem.sentence(word_count: 1)[0..20]) }
  let (:page2) { stub_model(InteractivePage, :id => 2, :name => Faker::Lorem.sentence(word_count: 1)[0..20]) }
  let (:activity) { stub_model(LightweightActivity, :id => 1, :name => Faker::Lorem.sentence(word_count: 2)[0..49], :description => Faker::Lorem.sentences(number: 3).join(" "), :visible_pages => [page1, page2]) }

  # Assigns
  before(:each) do
    assign(:activity, activity)
    assign(:pages, [page1, page2])
  end

  it 'shows the activity title' do
    render
    expect(rendered).to match /#{activity.name}/
  end

  it 'shows the activity description' do
    render
    expect(rendered).to match /#{activity.description}/
  end

  it 'has numbered list of pages with titles' do
    render
    expect(rendered).to have_css '.intro-mod ol li', :count => activity.visible_pages.length
    expect(rendered).to match /#{page1.name}/
    expect(rendered).to match /#{page2.name}/
  end

  it 'has a begin-activity button' do
    render
    expect(rendered).to have_css 'a div.submit input.button[type=submit]'
  end
end
