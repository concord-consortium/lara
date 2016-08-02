require 'spec_helper'

describe "sequences/edit" do
  let(:report_url) { "https://reporting.concord.org/" }
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user

    @sequence = assign(:sequence, stub_model(Sequence,
      :title => "MyString",
      :description => "MyText",
      :external_report_url => report_url
    ))
  end

  it "renders the edit sequence form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sequences_path(@sequence), :method => "post" do
      assert_select "input#sequence_title", :name => "sequence[title]"
      assert_select "textarea#sequence_description", :name => "sequence[description]"
      assert_select "select#sequence_theme_id", :name => "sequence[theme_id]" do
        assert_select 'option'
      end
      assert_select "input#sequence_external_report_url", :value => report_url
    end
  end
end
