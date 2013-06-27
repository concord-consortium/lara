require 'spec_helper'

describe "sequences/new" do
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user

    assign(:sequence, stub_model(Sequence,
      :title => "MyString",
      :description => "MyText"
    ).as_new_record)
  end

  it "renders new sequence form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sequences_path, :method => "post" do
      assert_select "input#sequence_title", :name => "sequence[title]"
      assert_select "textarea#sequence_description", :name => "sequence[description]"
    end
  end
end
