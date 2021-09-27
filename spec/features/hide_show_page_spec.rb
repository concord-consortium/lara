require 'spec_helper'
require 'uri'

feature 'Activity page can be hidden', :js => true do
  let(:user) { FactoryGirl.create(:admin) }
  before :each do
    login_as user, :scope => :user
  end

  feature 'marking page as visible or hidden' do
    let(:activity)               { FactoryGirl.create(:activity_with_page_and_or) }
    let(:activity_page)          { activity.pages.first }
    let(:edit_activity_page_url) { edit_activity_page_path(activity, activity_page) }
    let(:activity_page_url)      { activity_page_path(activity, activity_page) }

    scenario 'page can be marked as hidden' do
      activity_page.update_attributes!(is_hidden: true)

      visit activity_page_url
      expect(page.status_code).to eq(404)
    end

    scenario 'page can be marked as visible' do
      activity_page.update_attributes!(is_hidden: false)

      visit activity_page_url
      expect(page.status_code).to eq(200)
    end
  end

  feature 'the last visible page is considered as the end of the activity' do
    let (:activity)               { FactoryGirl.create(:activity_with_pages, pages_count: 3, student_report_enabled: true) }
    let (:third_page)             { activity.pages[2] }
    let (:edit_activity_page_url) { edit_activity_page_path(activity, third_page) }
    let (:second_page_url)        { activity_page_path(activity, activity.pages[1]) }

    scenario 'when the last page is marked as hidden, the previous one looks like the end of activity' do
      visit second_page_url
      expect(page).not_to have_button 'Generate a report'

      third_page.update_attributes!(is_hidden: true)
      visit second_page_url
      # it should look like the last one now
      expect(page).to have_button 'Generate a report'
    end

    feature 'when the activity has student reports disabled' do
      let (:activity)       { FactoryGirl.create(:activity_with_pages, pages_count: 3, student_report_enabled: false) }
      let (:third_page_url) { activity_page_path(activity, third_page) }

      scenario 'the generate report button should not be visible' do
        visit third_page_url
        expect(page).not_to have_button 'Generate a report'
      end
    end
  end
end
