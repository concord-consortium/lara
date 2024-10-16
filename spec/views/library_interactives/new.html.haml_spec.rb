require 'spec_helper'

describe "library_interactives/new", :type => :view do
  before(:each) do
    assign(:library_interactive, LibraryInteractive.new(
      :name => "MyString",
      :description => "MyText",
      :base_url => "http://example.com",
      :thumbnail_url => "MyText",
      :authoring_guidance => "MyText",
      :no_snapshots => false,
      :enable_learner_state => false,
      :hide_question_number => false,
      :has_report_url => false,
      :show_delete_data_button => false,
      :aspect_ratio_method => "MyString",
      :native_width => 1,
      :native_height => 1,
      :click_to_play => false,
      :full_window => false,
      :click_to_play_prompt => "MyString",
      :image_url => "MyString"
    ))
  end

  it "renders new library_interactive form" do
    render

    assert_select "form[action=?][method=?]", library_interactives_path, "post" do

      assert_select "input[name=?]", "library_interactive[name]"

      assert_select "textarea[name=?]", "library_interactive[description]"

      assert_select "textarea[name=?]", "library_interactive[base_url]"

      assert_select "textarea[name=?]", "library_interactive[thumbnail_url]"

      assert_select "textarea[name=?]", "library_interactive[authoring_guidance]"

      assert_select "input[name=?]", "library_interactive[no_snapshots]"

      assert_select "input[name=?]", "library_interactive[enable_learner_state]"

      assert_select "input[name=?]", "library_interactive[hide_question_number]"

      assert_select "input[name=?]", "library_interactive[has_report_url]"

      assert_select "input[name=?]", "library_interactive[show_delete_data_button]"

      assert_select "input[name=?]", "library_interactive[aspect_ratio_method]"

      assert_select "input[name=?]", "library_interactive[native_width]"

      assert_select "input[name=?]", "library_interactive[native_height]"

      assert_select "input[name=?]", "library_interactive[click_to_play]"

      assert_select "input[name=?]", "library_interactive[full_window]"

      assert_select "input[name=?]", "library_interactive[click_to_play_prompt]"

      assert_select "input[name=?]", "library_interactive[image_url]"
    end
  end
end
