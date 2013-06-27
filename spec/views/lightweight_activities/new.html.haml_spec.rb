require 'spec_helper'

describe "lightweight_activities/new" do

  it 'provides a form for naming and describing a Lightweight Activity' do
    assign(:activity, mock_model(LightweightActivity))
    render
    rendered.should match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
    rendered.should match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
    rendered.should match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
  end

end