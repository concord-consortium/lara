require 'spec_helper'
require 'uri'

# 2021-09-07 NP TODO: Reenable once we can hide page_items:
feature "Activity page", :js => true, :skip => true do
  # need an activity with at least a open response question
  let(:activity)      { FactoryGirl.create(:activity_with_page_and_or) }
  let(:user)          { FactoryGirl.create(:admin)  }
  let(:activity_page) { activity.pages.first }
  let(:question)     { activity.reportable_items.find {|q| q.class == Embeddable::OpenResponse} }
  let(:activity_page_url) { edit_activity_page_path(activity, activity_page) }
  let(:hideshow_url) { toggle_hideshow_page_item_path(question.p_item) }

  before :each do
    login_as user, :scope => :user
  end

  after :each do
    # wait for the show/hide call to end so that we don't race against the database cleaner
    wait_for_ajax()
  end

  scenario "is edited" do
    visit activity_page_url
    expect(page).to have_link 'hide', :href => hideshow_url
    expect(page).not_to have_link 'show', :href => hideshow_url
    expect(page).to have_css '.embeddable_options'
  end

  scenario "is edited and question is hidden" do
    visit activity_page_url

    click_link 'hide', :href => hideshow_url
    expect(page).to have_link 'show', :href => hideshow_url
    expect(page).not_to have_link 'hide', :href => hideshow_url
    expect(page).to have_selector('.embeddable_options', visible: false)
  end

  scenario "is edited and question is hidden and then shown" do
    visit activity_page_url

    click_link 'hide', :href => hideshow_url
    click_link 'show', :href => hideshow_url

    expect(page).to have_link 'hide', :href => hideshow_url
    expect(page).not_to have_link 'show', :href => hideshow_url
    expect(page).to have_css '.embeddable_options'
  end
end
