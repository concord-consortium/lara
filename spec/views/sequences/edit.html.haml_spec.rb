require 'spec_helper'

describe "sequences/edit" do
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user

    @sequence = assign(:sequence, stub_model(Sequence,
      :title => "MyString",
      :description => "MyText"
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
      assert_select "input#sequence_hide_read_aloud", :name => "sequence[hide_read_aloud]"
      assert_select "select#sequence_font_size", :name => "sequence[font_size]"
    end
  end
end
