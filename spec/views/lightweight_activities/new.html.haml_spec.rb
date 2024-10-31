require 'spec_helper'

describe "lightweight_activities/new" do

  let(:user)     { stub_model(User, :is_admin => false) }
  let(:activity) { mock_model(LightweightActivity, :copied_from_activity => nil) }

  before(:each) do
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'provides a form for naming and describing a Lightweight Activity' do
    assign(:activity, activity)
    render
    expect(rendered).to match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
    assert_select "input#lightweight_activity_name", :name => "lightweight_activity[name]"
    assert_select "textarea#lightweight_activity_description", :name => "lightweight_activity[description]"
  end

end