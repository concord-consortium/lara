require 'spec_helper'
require 'uri'

feature "Visiting all pages of a Sequence", :js => true do
  let(:sequence)          { FactoryGirl.create(:sequence_with_activity, seq_options) }
  let(:params)            { {} }
  let(:activities_count)  { 2 }
  let(:name) { 'teacher-view mode test Sequence'}
  let(:seq_options) do
    {
      title: name
    }
  end

  let(:url) do
    sequence_path(sequence, params: params, activities_count: activities_count)
  end

  feature "not as a teacher" do

    scenario "We shouldn't see 'teacher-view' in the url" do
      expect(sequence.activities.length).to be(activities_count)
      visit url
      expect(page).to have_content name
      expect(current_url).to_not match 'teacher-view'
      expect(sequence.activities.length).to be(2)
      expect(sequence.activities.first.pages.length).to be(2)
      expect(sequence.activities.last.pages.length).to be(2)
      expect(page).to have_content sequence.activities.first.name
      click_link(sequence.activities.first.name)
      click_button "Begin activity"
      # click_button "Next" -- oops JS tests don't seem to be running
    end
  end

  # TODO:
  # feature "as a teacher" do
  #   let(:params) { {mode: 'teacher-view' } }
  #   let(:name) { 'teacher-view mode test activity '}
  #   let(:act_options) { {name: name} }
  #   let(:seq_options) { {title: name} }

  #   scenario "We see teacher-view in the url" do
  #     expect(sequence.activities).to have(6).activities
  #     visit url
  #     expect(page).to have_content name
  #     click_button "Begin activity"
  #     expect(current_url).to match 'teacher-view'
  #   end
  # end

end
