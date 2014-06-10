require 'spec_helper'
require 'uri'

feature "Activity is run from the portal", :js => true, :slow => true do

  scenario "with a domain, external_id, and return url" do
    # need an activity with at least a open response question
  	activity = FactoryGirl.create(:activity_with_page_and_or)
    user     = FactoryGirl.create(:user_with_authentication)

    url = activity_path(activity, :params => {
		     :domain     => 'http://portal.org/',
		     :externalId => '1234',
		     :returnUrl  => 'http://portal.org/return/1234'
		     })

    visit url
    click_button "Begin activity"

    stub = stub_request(:post, "http://portal.org/return/1234").
	  with(:body => "[{\"type\":\"open_response\",\"question_id\":\"1\",\"answer\":\"something\",\"is_final\":false}]",
	       :headers => {'Authorization'=>'Bearer token', 'Content-Type'=>'application/json'}).
	  to_return(:status => 200, :body => "", :headers => {})

    fill_in 'embeddable_open_response_answer[answer_text]', :with => 'something'
    page.should have_content "Saving"
    page.should have_content "Saved"

	stub.should have_been_requested
  end
end


