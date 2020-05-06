require 'spec_helper'
require 'uri'

feature "Activity page", :js => true do
  # need an activity with at least a open response question
  let(:activity)     { FactoryGirl.create(:activity_with_page_and_or) }
  let(:user)       { FactoryGirl.create(:admin)  }
  let(:activity_page) { activity.pages.first }
  let(:question)     { activity.reportable_items.find {|q| q.class == Embeddable::OpenResponse} }
  let(:activity_page_url) { edit_activity_page_path(activity, activity_page) }
  let(:hideshow_url) { page_hideshow_embeddable_path(activity_page, question) }

  before :each do
    login_as user, :scope => :user
  end

  after :each do
    # wait for the show/hide call to end so that we don't race against the database cleaner
    wait_for_ajax()
  end

  scenario "is edited" do
    visit activity_page_url
    expect(page).to have_css('.ui-accordion-header')
    expect(page).to have_no_css '.embeddable_options'
  end

  scenario "is edited and question is shown" do
    visit activity_page_url

    first('.ui-accordion-header').click
    expect(page).to have_css '.embeddable_options'
  end

  scenario "is edited and question is shown and then hidden" do
    visit activity_page_url

    first('.ui-accordion-header').click
    first('.ui-accordion-header').click
    expect(page).to have_no_css '.embeddable_options'
  end
end
