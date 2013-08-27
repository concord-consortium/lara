require 'spec_helper'
require 'uri'

feature "Activity is run from the portal", :js => true do

  scenario "with a domain, external_id, and return url" do
    pending "need to fix url redirection in application controller."
    # need an activity with at least a open response question
  	activity = FactoryGirl.create(:activity_with_page_and_or)
    user     = FactoryGirl.create(:user_with_authentication)

    domain       = 'http://portal.com'
    external_id  = '1234'
    external_url = 'http://portal.com/return/1234'

    url = activity_path(activity)

    uri = URI.parse(url)
    uri.query = {
     :domain     => domain,
     :externalId => external_id,
     :returnUrl  => external_url
    }.to_query

    visit uri.to_s

    save_and_open_page
    click_button "Begin activity"
    fill_in 'embeddable_open_response_answer[answer_text]', :with => 'something'
    page.should have_content "Saving"
    page.should have_content "Saved"
    save_and_open_page
  end
end


