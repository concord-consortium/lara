require 'spec_helper'
require 'uri'

feature "Activity is run from the portal", :js => true do

  scenario "with a domain, external_id, and return url" do
    pending "need to fix url redirection in application controller."
    # need an activity with at least a open response question
  	activity = FactoryGirl.create(:activity_with_page_and_or)
    user     = FactoryGirl.create(:user_with_authentication)

    url = activity_path(activity, :params => {
		     :domain     => 'http://portal.com',
		     :externalId => '1234',
		     :returnUrl  => 'http://portal.com/return/1234'
		     })

    visit url

    save_and_open_page
    click_button "Begin activity"
    fill_in 'embeddable_open_response_answer[answer_text]', :with => 'something'
    page.should have_content "Saving"
    page.should have_content "Saved"
    save_and_open_page
  end
end


