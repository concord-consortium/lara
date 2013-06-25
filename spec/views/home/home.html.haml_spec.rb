require 'spec_helper'

describe "home/home" do
  let (:activity) { FactoryGirl.create(:public_activity) }
  let (:sequence) { FactoryGirl.create(:sequence) }

  it 'has heads for activities and sequences' do
    assign(:activities, [activity])
    assign(:sequences, [sequence])
    render
    rendered.should match /activity_listing_head/
    rendered.should match /sequence_listing_head/
  end
end
