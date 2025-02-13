require 'spec_helper'

describe "home/home" do
  let (:activity) { FactoryBot.create(:public_activity) }
  let (:sequence) { FactoryBot.create(:sequence) }

  it 'has heads for activities and sequences' do
    assign(:activities, [activity])
    assign(:sequences, [sequence])
    render
    expect(rendered).to match /activity_listing_head/
    expect(rendered).to match /sequence_listing_head/
  end
end
