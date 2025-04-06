# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence (:li_url) { Faker::Internet.url() }

  factory :library_interactive, class: LibraryInteractive do
    native_width { 100 }
    native_height { 200 }
    name { generate(:name) }
    base_url  { generate(:li_url) }
    image_url  { generate(:li_url) }
    thumbnail_url  { generate(:li_url) }
    created_at { Time.now.change(usec: 0) }
    updated_at { Time.now.change(usec: 0) }
    aspect_ratio_method { "DEFAULT" }
    authoring_guidance { "valid authoring_guidance" }
    click_to_play { false }
    click_to_play_prompt { "valid click_to_play_prompt" }
    description { "valid description" }
    enable_learner_state { false }
    full_window { false }
    has_report_url { false }
    no_snapshots { false }
    show_delete_data_button { false }
  end
end
