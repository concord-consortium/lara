# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_02_06_215441) do

  create_table "admin_events", charset: "utf8", force: :cascade do |t|
    t.string "kind"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approved_scripts", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.decimal "version", precision: 10, default: "1"
    t.string "json_url"
    t.text "authoring_metadata"
  end

  create_table "authentications", charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "index"
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "provider"], name: "index_authentications_on_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_authentications_on_user_id_and_provider", unique: true
  end

  create_table "authored_contents", charset: "utf8", force: :cascade do |t|
    t.string "content_type"
    t.string "url"
    t.bigint "user_id"
    t.string "container_type"
    t.bigint "container_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "index_authored_contents_on_container_type_and_container_id"
    t.index ["user_id"], name: "index_authored_contents_on_user_id"
  end

  create_table "collaboration_runs", charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "collaborators_data_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborators_data_url"], name: "collaboration_runs_endpoint_idx"
  end

  create_table "delayed_jobs", charset: "utf8", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "embeddable_external_scripts", charset: "utf8", force: :cascade do |t|
    t.bigint "approved_script_id"
    t.text "configuration"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_script_id"], name: "index_embeddable_external_scripts_on_approved_script_id"
  end

  create_table "embeddable_feedback_items", charset: "utf8", force: :cascade do |t|
    t.string "answer_type"
    t.bigint "answer_id"
    t.integer "score"
    t.text "feedback_text"
    t.text "answer_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "feedback_submission_id"
    t.string "feedback_submission_type"
    t.index ["answer_id", "answer_type"], name: "index_embeddable_feedback_items_on_answer_id_and_answer_type"
    t.index ["answer_type", "answer_id"], name: "index_embeddable_feedback_items_on_answer_type_and_answer_id"
    t.index ["feedback_submission_id", "feedback_submission_type"], name: "e_feed_item_submission_idx"
  end

  create_table "embeddable_image_question_answers", charset: "utf8", force: :cascade do |t|
    t.bigint "run_id"
    t.text "answer_text"
    t.string "image_url"
    t.integer "image_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "annotation", size: :long
    t.string "annotated_image_url"
    t.boolean "is_dirty", default: false
    t.boolean "is_final", default: false
    t.index ["image_question_id"], name: "index_on_image_question_id"
    t.index ["run_id", "image_question_id"], name: "index_on_run_and_question"
    t.index ["run_id"], name: "index_on_run_id"
  end

  create_table "embeddable_image_questions", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bg_source", default: "Shutterbug"
    t.string "bg_url"
    t.text "drawing_prompt"
    t.boolean "is_prediction", default: false
    t.boolean "give_prediction_feedback", default: false
    t.text "prediction_feedback"
    t.boolean "is_hidden", default: false
    t.text "hint"
    t.boolean "is_half_width", default: true
    t.integer "interactive_id"
    t.string "interactive_type"
    t.string "migration_status", default: "not migrated"
  end

  create_table "embeddable_labbook_answers", charset: "utf8", force: :cascade do |t|
    t.integer "run_id"
    t.integer "labbook_id"
    t.boolean "is_dirty", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["labbook_id"], name: "index_embeddable_labbook_answers_on_labbook_id"
    t.index ["run_id"], name: "index_embeddable_labbook_answers_on_run_id"
  end

  create_table "embeddable_labbooks", charset: "utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "action_type", default: 0, null: false
    t.string "name"
    t.text "prompt"
    t.string "custom_action_label"
    t.boolean "is_hidden", default: false
    t.string "interactive_type"
    t.bigint "interactive_id"
    t.text "hint"
    t.boolean "is_half_width", default: true
    t.index ["interactive_id"], name: "labbook_interactive_i_idx"
    t.index ["interactive_type", "interactive_id"], name: "index_embeddable_labbooks_on_interactive_type_and_interactive_id"
    t.index ["interactive_type"], name: "labbook_interactive_t_idx"
  end

  create_table "embeddable_multiple_choice_answers", charset: "utf8", force: :cascade do |t|
    t.integer "run_id"
    t.integer "multiple_choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_dirty", default: false
    t.boolean "is_final", default: false
    t.index ["multiple_choice_id"], name: "index_embeddable_multiple_choice_answers_on_multiple_choice_id"
    t.index ["run_id"], name: "index_embeddable_multiple_choice_answers_on_run_id"
  end

  create_table "embeddable_multiple_choice_choices", charset: "utf8", force: :cascade do |t|
    t.integer "multiple_choice_id"
    t.text "choice"
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "prompt"
    t.index ["multiple_choice_id"], name: "index_embeddable_multiple_choice_choices_on_multiple_choice_id"
  end

  create_table "embeddable_multiple_choices", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "custom", default: false
    t.boolean "enable_check_answer", default: true
    t.boolean "multi_answer", default: false
    t.boolean "show_as_menu", default: false
    t.boolean "is_prediction", default: false
    t.boolean "give_prediction_feedback", default: false
    t.text "prediction_feedback"
    t.string "layout", default: "vertical"
    t.boolean "is_hidden", default: false
    t.text "hint"
    t.boolean "is_half_width", default: true
    t.string "migration_status", default: "not migrated"
  end

  create_table "embeddable_open_response_answers", charset: "utf8", force: :cascade do |t|
    t.text "answer_text"
    t.integer "run_id"
    t.integer "open_response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_dirty", default: false
    t.boolean "is_final", default: false
    t.index ["open_response_id"], name: "index_embeddable_open_response_answers_on_open_response_id"
    t.index ["run_id", "open_response_id"], name: "index_open_response_answers_on_run_and_question"
  end

  create_table "embeddable_open_responses", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_prediction", default: false
    t.boolean "give_prediction_feedback", default: false
    t.text "prediction_feedback"
    t.string "default_text"
    t.boolean "is_hidden", default: false
    t.text "hint"
    t.boolean "is_half_width", default: true
    t.string "migration_status", default: "not migrated"
  end

  create_table "embeddable_plugins", charset: "utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "embeddable_id"
    t.string "embeddable_type"
    t.boolean "is_hidden", default: false
    t.boolean "is_half_width", default: true
  end

  create_table "embeddable_xhtmls", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_hidden", default: false
    t.boolean "is_half_width", default: false
    t.boolean "is_callout", default: true
  end

  create_table "global_interactive_states", charset: "utf8", force: :cascade do |t|
    t.integer "run_id"
    t.text "raw_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_id"], name: "index_global_interactive_states_on_run_id"
  end

  create_table "glossaries", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "json", size: :medium
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "legacy_glossary_resource_id"
    t.integer "project_id"
  end

  create_table "image_interactives", charset: "utf8", force: :cascade do |t|
    t.string "url"
    t.text "caption"
    t.text "credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_lightbox", default: true
    t.string "credit_url"
    t.boolean "is_hidden", default: false
    t.boolean "is_half_width", default: false
    t.string "migration_status", default: "not migrated"
  end

  create_table "imports", charset: "utf8", force: :cascade do |t|
    t.string "export_site"
    t.bigint "user_id"
    t.string "import_item_type"
    t.bigint "import_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_item_type", "import_item_id"], name: "index_imports_on_import_item_type_and_import_item_id"
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "interactive_items", charset: "utf8", force: :cascade do |t|
    t.integer "interactive_page_id"
    t.integer "interactive_id"
    t.string "interactive_type"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interactive_id", "interactive_type"], name: "interactive_items_interactive_idx"
    t.index ["interactive_page_id", "position"], name: "interactive_items_by_page_idx"
  end

  create_table "interactive_pages", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "lightweight_activity_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "sidebar"
    t.boolean "show_sidebar", default: false
    t.boolean "show_interactive", default: false
    t.boolean "show_info_assessment", default: false
    t.boolean "toggle_info_assessment", default: false
    t.string "workflow_state"
    t.string "layout", default: "l-6040"
    t.string "embeddable_display_mode", default: "stacked"
    t.string "sidebar_title", default: "Did you know?"
    t.text "additional_sections"
    t.boolean "is_hidden", default: false, null: false
    t.boolean "is_completion", default: false
    t.boolean "show_header", default: false
    t.index ["lightweight_activity_id", "position"], name: "interactive_pages_by_activity_idx"
  end

  create_table "interactive_run_states", charset: "utf8", force: :cascade do |t|
    t.string "interactive_type"
    t.bigint "interactive_id"
    t.bigint "run_id"
    t.text "raw_data", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "learner_url"
    t.boolean "is_dirty", default: false
    t.string "key"
    t.text "metadata"
    t.index ["interactive_id", "interactive_type"], name: "interactive_run_states_interactive_idx"
    t.index ["interactive_type", "interactive_id"], name: "index_interactive_run_states_on_interactive"
    t.index ["key"], name: "interactive_run_states_key_idx"
    t.index ["run_id"], name: "index_interactive_run_states_on_run_id"
    t.index ["run_id"], name: "interactive_run_states_run_id_idx"
  end

  create_table "library_interactives", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "authoring_guidance"
    t.text "base_url"
    t.string "thumbnail_url"
    t.string "image_url"
    t.string "click_to_play_prompt"
    t.boolean "click_to_play", default: false
    t.boolean "no_snapshots", default: false
    t.boolean "enable_learner_state", default: false
    t.boolean "has_report_url", default: false
    t.boolean "show_delete_data_button", default: true
    t.boolean "full_window", default: false
    t.string "aspect_ratio_method", default: "DEFAULT"
    t.integer "native_width"
    t.integer "native_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "export_hash"
    t.boolean "customizable", default: false
    t.boolean "authorable", default: false
    t.text "report_item_url"
    t.boolean "official", default: false
    t.boolean "hide_question_number", default: false
    t.index ["export_hash"], name: "library_interactives_export_hash_idx"
  end

  create_table "lightweight_activities", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "publication_status", default: "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offerings_count"
    t.text "related"
    t.text "description"
    t.integer "changed_by_id"
    t.boolean "is_official", default: false
    t.integer "time_to_complete"
    t.boolean "is_locked", default: false
    t.text "notes"
    t.string "thumbnail_url"
    t.integer "project_id"
    t.integer "portal_run_count", default: 0
    t.integer "layout", default: 0
    t.integer "editor_mode", default: 0
    t.string "publication_hash", limit: 40
    t.string "imported_activity_url"
    t.integer "copied_from_id"
    t.boolean "student_report_enabled", default: true
    t.text "last_report_service_hash"
    t.boolean "show_submit_button", default: true
    t.string "background_image"
    t.string "fixed_width_layout", default: "1100px"
    t.integer "glossary_id"
    t.boolean "defunct", default: false
    t.string "migration_status", default: "not_migrated"
    t.boolean "hide_read_aloud", default: false
    t.string "font_size", default: "normal"
    t.boolean "hide_question_numbers", default: false
    t.integer "rubric_id"
    t.index ["changed_by_id"], name: "index_lightweight_activities_on_changed_by_id"
    t.index ["project_id"], name: "index_lightweight_activities_on_project_id"
    t.index ["publication_status"], name: "lightweight_activities_publication_status_idx"
    t.index ["updated_at"], name: "lightweight_activities_updated_at_idx"
    t.index ["user_id"], name: "lightweight_activities_user_idx"
  end

  create_table "lightweight_activities_sequences", charset: "utf8", force: :cascade do |t|
    t.integer "lightweight_activity_id", default: 1, null: false
    t.integer "sequence_id", default: 1, null: false
    t.integer "position", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lightweight_activity_id"], name: "index_activities_sequence_join_by_activity"
    t.index ["sequence_id"], name: "index_activities_sequence_join_by_sequence"
  end

  create_table "linked_page_items", charset: "utf8", force: :cascade do |t|
    t.integer "primary_id"
    t.integer "secondary_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_id", "secondary_id", "label"], name: "index_linked_page_items_unique", unique: true
    t.index ["primary_id"], name: "index_linked_page_items_primary"
    t.index ["secondary_id"], name: "index_linked_page_items_secondary"
  end

  create_table "managed_interactives", charset: "utf8", force: :cascade do |t|
    t.integer "library_interactive_id"
    t.string "name"
    t.text "url_fragment"
    t.text "authored_state"
    t.boolean "is_hidden", default: false
    t.boolean "inherit_aspect_ratio_method", default: true
    t.string "custom_aspect_ratio_method"
    t.boolean "inherit_native_width", default: true
    t.integer "custom_native_width"
    t.boolean "inherit_native_height", default: true
    t.integer "custom_native_height"
    t.boolean "inherit_click_to_play", default: true
    t.boolean "custom_click_to_play", default: false
    t.boolean "inherit_full_window", default: true
    t.boolean "custom_full_window", default: false
    t.boolean "inherit_click_to_play_prompt", default: true
    t.string "custom_click_to_play_prompt"
    t.boolean "inherit_image_url", default: true
    t.string "custom_image_url"
    t.integer "linked_interactive_id"
    t.boolean "is_half_width", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linked_interactive_type"
    t.integer "legacy_ref_id"
    t.string "legacy_ref_type"
    t.boolean "inherit_hide_question_number", default: true
    t.boolean "custom_hide_question_number", default: false
    t.index ["legacy_ref_id", "legacy_ref_type"], name: "managed_interactive_legacy_idx"
    t.index ["library_interactive_id"], name: "managed_interactive_library_interactive_id_idx"
  end

  create_table "mc_answer_choices", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "answer_id"
    t.bigint "choice_id"
    t.index ["answer_id", "choice_id"], name: "index_mc_answer_choices_on_answer_id_and_choice_id"
    t.index ["answer_id"], name: "index_mc_answer_choices_on_answer_id"
    t.index ["choice_id", "answer_id"], name: "index_mc_answer_choices_on_choice_id_and_answer_id"
    t.index ["choice_id"], name: "index_mc_answer_choices_on_choice_id"
  end

  create_table "mw_interactives", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "native_width"
    t.integer "native_height"
    t.boolean "enable_learner_state", default: false
    t.boolean "has_report_url", default: false
    t.boolean "click_to_play"
    t.string "image_url"
    t.boolean "is_hidden", default: false
    t.integer "linked_interactive_id"
    t.boolean "full_window", default: false
    t.text "authored_state"
    t.string "model_library_url"
    t.boolean "no_snapshots", default: false
    t.string "click_to_play_prompt"
    t.boolean "show_delete_data_button", default: true
    t.boolean "is_half_width", default: false
    t.string "aspect_ratio_method", default: "DEFAULT"
    t.string "linked_interactive_type"
    t.text "report_item_url"
    t.boolean "hide_question_number", default: false
    t.index ["linked_interactive_id"], name: "index_mw_interactives_on_linked_interactive_id"
  end

  create_table "page_items", charset: "utf8", force: :cascade do |t|
    t.integer "interactive_page_id"
    t.integer "embeddable_id"
    t.string "embeddable_type"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "old_section"
    t.bigint "section_id"
    t.string "column"
    t.integer "section_position"
    t.index ["embeddable_id", "embeddable_type"], name: "index_page_items_on_embeddable_id_and_embeddable_type"
    t.index ["section_id", "position"], name: "index_page_items_on_section_id_and_position"
    t.index ["section_id"], name: "index_page_items_on_section_id"
  end

  create_table "pending_portal_publications", charset: "utf8", force: :cascade do |t|
    t.integer "portal_publication_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portal_publication_id"], name: "unique_publications_per_portal", unique: true
  end

  create_table "plugin_learner_states", charset: "utf8", force: :cascade do |t|
    t.integer "plugin_id"
    t.integer "user_id"
    t.integer "run_id"
    t.string "shared_learner_state_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "state"
    t.index ["plugin_id", "run_id"], name: "plugin_run__states"
    t.index ["shared_learner_state_key", "run_id"], name: "shared_run_plugin_states"
    t.index ["shared_learner_state_key", "user_id"], name: "shared_user_plugin_states"
  end

  create_table "plugins", charset: "utf8", force: :cascade do |t|
    t.string "approved_script_id"
    t.integer "plugin_scope_id"
    t.string "plugin_scope_type"
    t.text "author_data"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shared_learner_state_key"
    t.string "component_label"
    t.index ["plugin_scope_id", "plugin_scope_type"], name: "plugin_scopes"
  end

  create_table "portal_publications", charset: "utf8", force: :cascade do |t|
    t.string "portal_url"
    t.text "response"
    t.boolean "success"
    t.integer "publishable_id"
    t.string "publishable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "publication_hash", limit: 40
    t.integer "publication_time"
    t.text "sent_data"
    t.index ["publishable_id", "publishable_type"], name: "index_portal_publications_on_publishable_id_and_publishable_type"
  end

  create_table "project_admins", charset: "utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_admins_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_admins_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_admins_on_user_id"
  end

  create_table "projects", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.string "logo_lara"
    t.string "url"
    t.text "footer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "about"
    t.string "logo_ap"
    t.string "project_key"
    t.text "copyright"
    t.string "copyright_image_url"
    t.text "collaborators"
    t.string "funders_image_url"
    t.string "collaborators_image_url"
    t.string "contact_email"
    t.index ["project_key"], name: "index_projects_on_project_key", unique: true
  end

  create_table "rubrics", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "authored_content_id"
    t.string "doc_url"
    t.index ["authored_content_id"], name: "index_rubrics_on_authored_content_id"
  end

  create_table "runs", charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "run_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.integer "activity_id"
    t.string "remote_id"
    t.integer "page_id"
    t.string "remote_endpoint"
    t.integer "sequence_id"
    t.integer "sequence_run_id"
    t.boolean "is_dirty", default: false
    t.integer "collaboration_run_id"
    t.text "class_info_url"
    t.string "context_id"
    t.string "platform_id"
    t.string "platform_user_id"
    t.string "resource_link_id"
    t.integer "status", default: 0
    t.index ["activity_id"], name: "index_runs_on_activity_id"
    t.index ["collaboration_run_id"], name: "runs_collaboration_idx"
    t.index ["key"], name: "index_runs_on_key"
    t.index ["remote_endpoint"], name: "index_runs_on_remote_endpoint"
    t.index ["sequence_id"], name: "index_runs_on_sequence_id"
    t.index ["sequence_run_id"], name: "index_runs_on_sequence_run_id"
    t.index ["status"], name: "index_runs_on_status"
    t.index ["updated_at"], name: "index_runs_on_updated_at"
    t.index ["user_id", "activity_id"], name: "index_runs_on_user_id_and_activity_id"
    t.index ["user_id", "remote_id", "remote_endpoint"], name: "runs_user_remote_endpt_idx"
    t.index ["user_id"], name: "index_runs_on_user_id"
  end

  create_table "sections", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.boolean "show"
    t.string "layout"
    t.integer "position"
    t.bigint "interactive_page_id"
    t.boolean "can_collapse_small"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["interactive_page_id", "position"], name: "index_sections_on_interactive_page_id_and_position"
    t.index ["interactive_page_id"], name: "index_sections_on_interactive_page_id"
  end

  create_table "sequence_runs", charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "sequence_id"
    t.string "remote_id"
    t.string "remote_endpoint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "context_id"
    t.string "class_info_url"
    t.string "platform_id"
    t.string "platform_user_id"
    t.string "resource_link_id"
    t.index ["key"], name: "sequence_runs_key_idx"
    t.index ["sequence_id"], name: "index_sequence_runs_on_sequence_id"
    t.index ["user_id"], name: "index_sequence_runs_on_user_id"
  end

  create_table "sequences", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "project_id"
    t.text "logo"
    t.string "publication_status", default: "private"
    t.boolean "is_official", default: false
    t.string "display_title"
    t.string "thumbnail_url"
    t.text "abstract"
    t.string "publication_hash", limit: 40
    t.string "imported_activity_url"
    t.text "last_report_service_hash"
    t.string "background_image"
    t.string "fixed_width_layout", default: "1100px"
    t.boolean "defunct", default: false
    t.string "migration_status", default: "not_migrated"
    t.boolean "hide_read_aloud", default: false
    t.string "font_size", default: "normal"
    t.integer "layout_override", default: 0
    t.boolean "hide_question_numbers", default: false
    t.index ["project_id"], name: "index_sequences_on_project_id"
    t.index ["updated_at"], name: "sequences_updated_at_idx"
    t.index ["user_id"], name: "index_sequences_on_user_id"
  end

  create_table "settings", charset: "utf8", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.boolean "is_author", default: false
    t.text "api_key"
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "video_interactives", charset: "utf8", force: :cascade do |t|
    t.string "poster_url"
    t.text "caption"
    t.text "credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "width", default: 556, null: false
    t.integer "height", default: 240, null: false
    t.boolean "is_hidden", default: false
    t.boolean "is_half_width", default: false
    t.string "migration_status", default: "not migrated"
  end

  create_table "video_sources", charset: "utf8", force: :cascade do |t|
    t.string "url", null: false
    t.string "format", null: false
    t.integer "video_interactive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["video_interactive_id"], name: "index_video_sources_on_video_interactive_id"
  end

end
