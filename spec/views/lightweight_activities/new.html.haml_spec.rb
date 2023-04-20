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
    expect(rendered).to match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
    expect(rendered).to match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
  end

end