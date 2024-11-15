require 'spec_helper'

describe "library_interactives/index", type: :view do
  before(:each) do
    assign(:library_interactives, [
      LibraryInteractive.create!(
        name: "Name",
        description: "MyText",
        base_url: "http://example.com/",
        thumbnail_url: "http://example.com/",
        authoring_guidance: "MyText",
        no_snapshots: false,
        enable_learner_state: false,
        hide_question_number: false,
        has_report_url: false,
        show_delete_data_button: false,
        aspect_ratio_method: "Aspect Ratio Method",
        native_width: 2,
        native_height: 3,
        click_to_play: false,
        full_window: false,
        click_to_play_prompt: "Click To Play Prompt",
        image_url: "http://example.com/"
      ),
      LibraryInteractive.create!(
        name: "Name",
        description: "MyText",
        base_url: "http://example.com/",
        thumbnail_url: "http://example.com/",
        authoring_guidance: "MyText",
        no_snapshots: false,
        enable_learner_state: false,
        hide_question_number: false,
        has_report_url: false,
        show_delete_data_button: false,
        aspect_ratio_method: "Aspect Ratio Method",
        native_width: 2,
        native_height: 3,
        click_to_play: false,
        full_window: false,
        click_to_play_prompt: "Click To Play Prompt",
        image_url: "http://example.com/"
      )
    ])
  end

  it "renders a list of library_interactives" do
    render
    assert_select "li.item", count: 2
  end
end
