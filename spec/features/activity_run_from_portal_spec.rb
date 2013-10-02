require 'spec_helper'
require 'uri'

feature "Activity is run from the portal", :js => true, :slow => true do

  scenario "with a domain, external_id, and return url" do

    # need an activity with at least a open response question
  	activity = FactoryGirl.create(:activity_with_page_and_or)
    user     = FactoryGirl.create(:user_with_authentication)

    url = activity_path(activity, :params => {
		     :domain     => 'http://portal.com',
		     :externalId => '1234',
		     :returnUrl  => 'http://portal.com/return/1234'
		     })

    visit url

    click_button "Begin activity"

    stub = stub_request(:post, "http://portal.com/return/1234").
	  with(:body => "[{\"type\":\"open_response\",\"question_id\":\"1\",\"answer\":\"something\"}]",
	       :headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
	  to_return(:status => 200, :body => "", :headers => {})

    fill_in 'embeddable_open_response_answer[answer_text]', :with => 'something'
    page.should have_content "Saving"
    page.should have_content "Saved"

    # The 'Bearer token' comes from the mocked omniauth authentication
    # TODO: Not quite sure why this happens 3 times?
	  stub.should have_been_requested.times(3)
  end
end


