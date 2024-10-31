# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20241018134619) do

  create_table "admin_events", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "message",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "approved_scripts", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "url",                limit: 255
    t.text     "description",        limit: 65535
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "label",              limit: 255
    t.decimal  "version",                          precision: 10, default: 1
    t.string   "json_url",           limit: 255
    t.text     "authoring_metadata", limit: 65535
  end

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "index",      limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.string   "token",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "authentications", ["uid", "provider"], name: "index_authentications_on_uid_and_provider", unique: true, using: :btree
  add_index "authentications", ["user_id", "provider"], name: "index_authentications_on_user_id_and_provider", unique: true, using: :btree

  create_table "authored_contents", force: :cascade do |t|
    t.string   "content_type",   limit: 255
    t.string   "url",            limit: 255
    t.integer  "user_id",        limit: 4
    t.integer  "container_id",   limit: 4
    t.string   "container_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "c_rater_feedback_items", force: :cascade do |t|
    t.text     "answer_text",              limit: 65535
    t.integer  "answer_id",                limit: 4
    t.string   "answer_type",              limit: 255
    t.string   "item_id",                  limit: 255
    t.string   "status",                   limit: 255
    t.integer  "score",                    limit: 4
    t.text     "feedback_text",            limit: 65535
    t.text     "response_info",            limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "feedback_submission_id",   limit: 4
    t.string   "feedback_submission_type", limit: 255
  end

  add_index "c_rater_feedback_items", ["answer_id", "answer_type"], name: "c_rat_feed_it_answer_idx", using: :btree
  add_index "c_rater_feedback_items", ["feedback_submission_id", "feedback_submission_type"], name: "c_rater_feed_item_submission_idx", using: :btree

  create_table "c_rater_feedback_submissions", force: :cascade do |t|
    t.integer  "usefulness_score",     limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "interactive_page_id",  limit: 4
    t.integer  "run_id",               limit: 4
    t.integer  "collaboration_run_id", limit: 4
    t.integer  "base_submission_id",   limit: 4
  end

  add_index "c_rater_feedback_submissions", ["base_submission_id"], name: "feedback_submissions_base_sub_id_idx", using: :btree
  add_index "c_rater_feedback_submissions", ["interactive_page_id", "run_id", "created_at"], name: "c_rater_fed_submission_page_run_created_idx", using: :btree

  create_table "c_rater_item_settings", force: :cascade do |t|
    t.string   "item_id",          limit: 255
    t.integer  "score_mapping_id", limit: 4
    t.integer  "provider_id",      limit: 4
    t.string   "provider_type",    limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "c_rater_item_settings", ["provider_id", "provider_type"], name: "c_rat_set_prov_idx", using: :btree
  add_index "c_rater_item_settings", ["score_mapping_id"], name: "index_c_rater_settings_on_score_mapping_id", using: :btree

  create_table "c_rater_score_mappings", force: :cascade do |t|
    t.text     "mapping",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "description",   limit: 255
    t.integer  "user_id",       limit: 4
    t.integer  "changed_by_id", limit: 4
  end

  create_table "collaboration_runs", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "collaborators_data_url", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "collaboration_runs", ["collaborators_data_url"], name: "collaboration_runs_endpoint_idx", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "embeddable_external_scripts", force: :cascade do |t|
    t.integer  "approved_script_id", limit: 4
    t.text     "configuration",      limit: 65535
    t.text     "description",        limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "embeddable_feedback_items", force: :cascade do |t|
    t.integer  "answer_id",                limit: 4
    t.string   "answer_type",              limit: 255
    t.integer  "score",                    limit: 4
    t.text     "feedback_text",            limit: 65535
    t.text     "answer_text",              limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "feedback_submission_id",   limit: 4
    t.string   "feedback_submission_type", limit: 255
  end

  add_index "embeddable_feedback_items", ["answer_id", "answer_type"], name: "index_embeddable_feedback_items_on_answer_id_and_answer_type", using: :btree
  add_index "embeddable_feedback_items", ["feedback_submission_id", "feedback_submission_type"], name: "e_feed_item_submission_idx", using: :btree

  create_table "embeddable_image_question_answers", force: :cascade do |t|
    t.integer  "run_id",              limit: 4
    t.text     "answer_text",         limit: 65535
    t.string   "image_url",           limit: 255
    t.integer  "image_question_id",   limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.text     "annotation",          limit: 4294967295
    t.string   "annotated_image_url", limit: 255
    t.boolean  "is_dirty",                               default: false
    t.boolean  "is_final",                               default: false
  end

  add_index "embeddable_image_question_answers", ["image_question_id"], name: "index_on_image_question_id", using: :btree
  add_index "embeddable_image_question_answers", ["run_id", "image_question_id"], name: "index_on_run_and_question", using: :btree
  add_index "embeddable_image_question_answers", ["run_id"], name: "index_on_run_id", using: :btree

  create_table "embeddable_image_questions", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.text     "prompt",                           limit: 65535
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "bg_source",                        limit: 255,   default: "Shutterbug"
    t.string   "bg_url",                           limit: 255
    t.text     "drawing_prompt",                   limit: 65535
    t.boolean  "is_prediction",                                  default: false
    t.boolean  "give_prediction_feedback",                       default: false
    t.text     "prediction_feedback",              limit: 65535
    t.boolean  "is_hidden",                                      default: false
    t.text     "hint",                             limit: 65535
    t.boolean  "is_half_width",                                  default: true
    t.boolean  "show_in_featured_question_report",               default: true
    t.integer  "interactive_id",                   limit: 4
    t.string   "interactive_type",                 limit: 255
    t.string   "migration_status",                 limit: 255,   default: "not migrated"
  end

  create_table "embeddable_labbook_answers", force: :cascade do |t|
    t.integer  "run_id",     limit: 4
    t.integer  "labbook_id", limit: 4
    t.boolean  "is_dirty",             default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "embeddable_labbook_answers", ["labbook_id"], name: "index_embeddable_labbook_answers_on_labbook_id", using: :btree
  add_index "embeddable_labbook_answers", ["run_id"], name: "index_embeddable_labbook_answers_on_run_id", using: :btree

  create_table "embeddable_labbooks", force: :cascade do |t|
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "action_type",                      limit: 4,     default: 0,     null: false
    t.string   "name",                             limit: 255
    t.text     "prompt",                           limit: 65535
    t.string   "custom_action_label",              limit: 255
    t.boolean  "is_hidden",                                      default: false
    t.integer  "interactive_id",                   limit: 4
    t.string   "interactive_type",                 limit: 255
    t.text     "hint",                             limit: 65535
    t.boolean  "is_half_width",                                  default: true
    t.boolean  "show_in_featured_question_report",               default: true
  end

  add_index "embeddable_labbooks", ["interactive_id"], name: "labbook_interactive_i_idx", using: :btree
  add_index "embeddable_labbooks", ["interactive_type"], name: "labbook_interactive_t_idx", using: :btree

  create_table "embeddable_multiple_choice_answers", force: :cascade do |t|
    t.integer  "run_id",             limit: 4
    t.integer  "multiple_choice_id", limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_dirty",                     default: false
    t.boolean  "is_final",                     default: false
  end

  add_index "embeddable_multiple_choice_answers", ["multiple_choice_id"], name: "index_embeddable_multiple_choice_answers_on_multiple_choice_id", using: :btree
  add_index "embeddable_multiple_choice_answers", ["run_id"], name: "index_embeddable_multiple_choice_answers_on_run_id", using: :btree

  create_table "embeddable_multiple_choice_choices", force: :cascade do |t|
    t.integer  "multiple_choice_id", limit: 4
    t.text     "choice",             limit: 65535
    t.boolean  "is_correct"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "prompt",             limit: 65535
  end

  add_index "embeddable_multiple_choice_choices", ["multiple_choice_id"], name: "index_embeddable_multiple_choice_choices_on_multiple_choice_id", using: :btree

  create_table "embeddable_multiple_choices", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.text     "prompt",                           limit: 65535
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.boolean  "custom",                                         default: false
    t.boolean  "enable_check_answer",                            default: true
    t.boolean  "multi_answer",                                   default: false
    t.boolean  "show_as_menu",                                   default: false
    t.boolean  "is_prediction",                                  default: false
    t.boolean  "give_prediction_feedback",                       default: false
    t.text     "prediction_feedback",              limit: 65535
    t.string   "layout",                           limit: 255,   default: "vertical"
    t.boolean  "is_hidden",                                      default: false
    t.text     "hint",                             limit: 65535
    t.boolean  "is_half_width",                                  default: true
    t.boolean  "show_in_featured_question_report",               default: true
    t.string   "migration_status",                 limit: 255,   default: "not migrated"
  end

  create_table "embeddable_open_response_answers", force: :cascade do |t|
    t.text     "answer_text",      limit: 65535
    t.integer  "run_id",           limit: 4
    t.integer  "open_response_id", limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "is_dirty",                       default: false
    t.boolean  "is_final",                       default: false
  end

  add_index "embeddable_open_response_answers", ["open_response_id"], name: "index_embeddable_open_response_answers_on_open_response_id", using: :btree
  add_index "embeddable_open_response_answers", ["run_id", "open_response_id"], name: "index_open_response_answers_on_run_and_question", using: :btree
  add_index "embeddable_open_response_answers", ["run_id"], name: "index_embeddable_open_response_answers_on_run_id", using: :btree

  create_table "embeddable_open_responses", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.text     "prompt",                           limit: 65535
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.boolean  "is_prediction",                                  default: false
    t.boolean  "give_prediction_feedback",                       default: false
    t.text     "prediction_feedback",              limit: 65535
    t.string   "default_text",                     limit: 255
    t.boolean  "is_hidden",                                      default: false
    t.text     "hint",                             limit: 65535
    t.boolean  "is_half_width",                                  default: true
    t.boolean  "show_in_featured_question_report",               default: true
    t.string   "migration_status",                 limit: 255,   default: "not migrated"
  end

  create_table "embeddable_plugins", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "embeddable_id",   limit: 4
    t.string   "embeddable_type", limit: 255
    t.boolean  "is_hidden",                   default: false
    t.boolean  "is_half_width",               default: true
  end

  create_table "embeddable_xhtmls", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "content",       limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "is_hidden",                   default: false
    t.boolean  "is_half_width",               default: false
    t.boolean  "is_callout",                  default: true
  end

  create_table "global_interactive_states", force: :cascade do |t|
    t.integer  "run_id",     limit: 4
    t.text     "raw_data",   limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "global_interactive_states", ["run_id"], name: "index_global_interactive_states_on_run_id", using: :btree

  create_table "glossaries", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.text     "json",                        limit: 16777215
    t.integer  "user_id",                     limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "legacy_glossary_resource_id", limit: 255
    t.integer  "project_id",                  limit: 4
  end

  create_table "image_interactives", force: :cascade do |t|
    t.string   "url",              limit: 255
    t.text     "caption",          limit: 65535
    t.text     "credit",           limit: 65535
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "show_lightbox",                  default: true
    t.string   "credit_url",       limit: 255
    t.boolean  "is_hidden",                      default: false
    t.boolean  "is_half_width",                  default: false
    t.string   "migration_status", limit: 255,   default: "not migrated"
  end

  create_table "imports", force: :cascade do |t|
    t.string   "export_site",      limit: 255
    t.integer  "user_id",          limit: 4
    t.integer  "import_item_id",   limit: 4
    t.string   "import_item_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "interactive_items", force: :cascade do |t|
    t.integer  "interactive_page_id", limit: 4
    t.integer  "interactive_id",      limit: 4
    t.string   "interactive_type",    limit: 255
    t.integer  "position",            limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "interactive_items", ["interactive_id", "interactive_type"], name: "interactive_items_interactive_idx", using: :btree
  add_index "interactive_items", ["interactive_page_id", "position"], name: "interactive_items_by_page_idx", using: :btree

  create_table "interactive_pages", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.integer  "lightweight_activity_id", limit: 4
    t.integer  "position",                limit: 4
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.text     "sidebar",                 limit: 65535
    t.boolean  "show_sidebar",                          default: false
    t.boolean  "show_interactive",                      default: false
    t.boolean  "show_info_assessment",                  default: false
    t.boolean  "toggle_info_assessment",                default: false
    t.string   "workflow_state",          limit: 255
    t.string   "layout",                  limit: 255,   default: "l-6040"
    t.string   "embeddable_display_mode", limit: 255,   default: "stacked"
    t.string   "sidebar_title",           limit: 255,   default: "Did you know?"
    t.text     "additional_sections",     limit: 65535
    t.boolean  "is_hidden",                             default: false,           null: false
    t.boolean  "is_completion",                         default: false
    t.boolean  "show_header",                           default: false
  end

  add_index "interactive_pages", ["lightweight_activity_id", "position"], name: "interactive_pages_by_activity_idx", using: :btree

  create_table "interactive_run_states", force: :cascade do |t|
    t.integer  "interactive_id",   limit: 4
    t.string   "interactive_type", limit: 255
    t.integer  "run_id",           limit: 4
    t.text     "raw_data",         limit: 16777215
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "learner_url",      limit: 65535
    t.boolean  "is_dirty",                          default: false
    t.string   "key",              limit: 255
    t.text     "metadata",         limit: 65535
  end

  add_index "interactive_run_states", ["interactive_id", "interactive_type"], name: "interactive_run_states_interactive_idx", using: :btree
  add_index "interactive_run_states", ["key"], name: "interactive_run_states_key_idx", using: :btree
  add_index "interactive_run_states", ["run_id"], name: "interactive_run_states_run_id_idx", using: :btree

  create_table "library_interactives", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.text     "description",             limit: 65535
    t.text     "authoring_guidance",      limit: 65535
    t.text     "base_url",                limit: 65535
    t.string   "thumbnail_url",           limit: 255
    t.string   "image_url",               limit: 255
    t.string   "click_to_play_prompt",    limit: 255
    t.boolean  "click_to_play",                         default: false
    t.boolean  "no_snapshots",                          default: false
    t.boolean  "enable_learner_state",                  default: false
    t.boolean  "has_report_url",                        default: false
    t.boolean  "show_delete_data_button",               default: true
    t.boolean  "full_window",                           default: false
    t.string   "aspect_ratio_method",     limit: 255,   default: "DEFAULT"
    t.integer  "native_width",            limit: 4
    t.integer  "native_height",           limit: 4
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "export_hash",             limit: 255
    t.boolean  "customizable",                          default: false
    t.boolean  "authorable",                            default: false
    t.text     "report_item_url",         limit: 65535
    t.boolean  "official",                              default: false
    t.boolean  "hide_question_number",                  default: false
  end

  add_index "library_interactives", ["export_hash"], name: "library_interactives_export_hash_idx", using: :btree

  create_table "lightweight_activities", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.integer  "user_id",                  limit: 4
    t.string   "publication_status",       limit: 255,   default: "private"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "offerings_count",          limit: 4
    t.text     "related",                  limit: 65535
    t.text     "description",              limit: 65535
    t.integer  "changed_by_id",            limit: 4
    t.boolean  "is_official",                            default: false
    t.integer  "time_to_complete",         limit: 4
    t.boolean  "is_locked",                              default: false
    t.text     "notes",                    limit: 65535
    t.string   "thumbnail_url",            limit: 255
    t.integer  "project_id",               limit: 4
    t.integer  "portal_run_count",         limit: 4,     default: 0
    t.integer  "layout",                   limit: 4,     default: 0
    t.integer  "editor_mode",              limit: 4,     default: 0
    t.string   "publication_hash",         limit: 40
    t.string   "imported_activity_url",    limit: 255
    t.integer  "copied_from_id",           limit: 4
    t.boolean  "student_report_enabled",                 default: true
    t.text     "last_report_service_hash", limit: 65535
    t.boolean  "show_submit_button",                     default: true
    t.string   "background_image",         limit: 255
    t.string   "fixed_width_layout",       limit: 255,   default: "1100px"
    t.integer  "glossary_id",              limit: 4
    t.boolean  "defunct",                                default: false
    t.string   "migration_status",         limit: 255,   default: "not_migrated"
    t.boolean  "hide_read_aloud",                        default: false
    t.string   "font_size",                limit: 255,   default: "normal"
    t.boolean  "hide_question_numbers",                  default: false
    t.integer  "rubric_id",                limit: 4
  end

  add_index "lightweight_activities", ["changed_by_id"], name: "index_lightweight_activities_on_changed_by_id", using: :btree
  add_index "lightweight_activities", ["project_id"], name: "index_lightweight_activities_on_project_id", using: :btree
  add_index "lightweight_activities", ["publication_status"], name: "lightweight_activities_publication_status_idx", using: :btree
  add_index "lightweight_activities", ["updated_at"], name: "lightweight_activities_updated_at_idx", using: :btree
  add_index "lightweight_activities", ["user_id"], name: "lightweight_activities_user_idx", using: :btree

  create_table "lightweight_activities_sequences", force: :cascade do |t|
    t.integer  "lightweight_activity_id", limit: 4, default: 1, null: false
    t.integer  "sequence_id",             limit: 4, default: 1, null: false
    t.integer  "position",                limit: 4, default: 1
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "lightweight_activities_sequences", ["lightweight_activity_id"], name: "index_activities_sequence_join_by_activity", using: :btree
  add_index "lightweight_activities_sequences", ["sequence_id"], name: "index_activities_sequence_join_by_sequence", using: :btree

  create_table "linked_page_items", force: :cascade do |t|
    t.integer  "primary_id",   limit: 4
    t.integer  "secondary_id", limit: 4
    t.string   "label",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "linked_page_items", ["primary_id", "secondary_id", "label"], name: "index_linked_page_items_unique", unique: true, using: :btree
  add_index "linked_page_items", ["primary_id"], name: "index_linked_page_items_primary", using: :btree
  add_index "linked_page_items", ["secondary_id"], name: "index_linked_page_items_secondary", using: :btree

  create_table "managed_interactives", force: :cascade do |t|
    t.integer  "library_interactive_id",           limit: 4
    t.string   "name",                             limit: 255
    t.text     "url_fragment",                     limit: 65535
    t.text     "authored_state",                   limit: 65535
    t.boolean  "is_hidden",                                      default: false
    t.boolean  "inherit_aspect_ratio_method",                    default: true
    t.string   "custom_aspect_ratio_method",       limit: 255
    t.boolean  "inherit_native_width",                           default: true
    t.integer  "custom_native_width",              limit: 4
    t.boolean  "inherit_native_height",                          default: true
    t.integer  "custom_native_height",             limit: 4
    t.boolean  "inherit_click_to_play",                          default: true
    t.boolean  "custom_click_to_play",                           default: false
    t.boolean  "inherit_full_window",                            default: true
    t.boolean  "custom_full_window",                             default: false
    t.boolean  "inherit_click_to_play_prompt",                   default: true
    t.string   "custom_click_to_play_prompt",      limit: 255
    t.boolean  "inherit_image_url",                              default: true
    t.string   "custom_image_url",                 limit: 255
    t.integer  "linked_interactive_id",            limit: 4
    t.boolean  "is_half_width",                                  default: false
    t.boolean  "show_in_featured_question_report",               default: true
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "linked_interactive_type",          limit: 255
    t.integer  "legacy_ref_id",                    limit: 4
    t.string   "legacy_ref_type",                  limit: 255
    t.boolean  "inherit_hide_question_number",                   default: true
    t.boolean  "custom_hide_question_number",                    default: false
  end

  add_index "managed_interactives", ["legacy_ref_id", "legacy_ref_type"], name: "managed_interactive_legacy_idx", using: :btree
  add_index "managed_interactives", ["library_interactive_id"], name: "managed_interactive_library_interactive_id_idx", using: :btree

  create_table "mc_answer_choices", id: false, force: :cascade do |t|
    t.integer "answer_id", limit: 4
    t.integer "choice_id", limit: 4
  end

  add_index "mc_answer_choices", ["answer_id", "choice_id"], name: "index_mc_answer_choices_on_answer_id_and_choice_id", using: :btree
  add_index "mc_answer_choices", ["choice_id", "answer_id"], name: "index_mc_answer_choices_on_choice_id_and_answer_id", using: :btree

  create_table "mw_interactives", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.text     "url",                              limit: 65535
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "native_width",                     limit: 4
    t.integer  "native_height",                    limit: 4
    t.boolean  "enable_learner_state",                           default: false
    t.boolean  "has_report_url",                                 default: false
    t.boolean  "click_to_play"
    t.string   "image_url",                        limit: 255
    t.boolean  "is_hidden",                                      default: false
    t.integer  "linked_interactive_id",            limit: 4
    t.boolean  "full_window",                                    default: false
    t.text     "authored_state",                   limit: 65535
    t.string   "model_library_url",                limit: 255
    t.boolean  "no_snapshots",                                   default: false
    t.string   "click_to_play_prompt",             limit: 255
    t.boolean  "show_delete_data_button",                        default: true
    t.boolean  "is_half_width",                                  default: false
    t.boolean  "show_in_featured_question_report",               default: true
    t.string   "aspect_ratio_method",              limit: 255,   default: "DEFAULT"
    t.string   "linked_interactive_type",          limit: 255
    t.text     "report_item_url",                  limit: 65535
    t.boolean  "hide_question_number",                           default: false
  end

  add_index "mw_interactives", ["linked_interactive_id"], name: "index_mw_interactives_on_linked_interactive_id", using: :btree

  create_table "page_items", force: :cascade do |t|
    t.integer  "interactive_page_id", limit: 4
    t.integer  "embeddable_id",       limit: 4
    t.string   "embeddable_type",     limit: 255
    t.integer  "position",            limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "old_section",         limit: 255
    t.integer  "section_id",          limit: 4
    t.string   "column",              limit: 255
    t.integer  "section_position",    limit: 4
  end

  add_index "page_items", ["embeddable_id", "embeddable_type"], name: "index_page_items_on_embeddable_id_and_embeddable_type", using: :btree
  add_index "page_items", ["section_id", "position"], name: "index_page_items_on_section_id_and_position", using: :btree

  create_table "pending_portal_publications", force: :cascade do |t|
    t.integer  "portal_publication_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "pending_portal_publications", ["portal_publication_id"], name: "unique_publications_per_portal", unique: true, using: :btree

  create_table "plugin_learner_states", force: :cascade do |t|
    t.integer  "plugin_id",                limit: 4
    t.integer  "user_id",                  limit: 4
    t.integer  "run_id",                   limit: 4
    t.string   "shared_learner_state_key", limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.text     "state",                    limit: 65535
  end

  add_index "plugin_learner_states", ["plugin_id", "run_id"], name: "plugin_run__states", using: :btree
  add_index "plugin_learner_states", ["shared_learner_state_key", "run_id"], name: "shared_run_plugin_states", using: :btree
  add_index "plugin_learner_states", ["shared_learner_state_key", "user_id"], name: "shared_user_plugin_states", using: :btree

  create_table "plugins", force: :cascade do |t|
    t.string   "approved_script_id",       limit: 255
    t.integer  "plugin_scope_id",          limit: 4
    t.string   "plugin_scope_type",        limit: 255
    t.text     "author_data",              limit: 65535
    t.text     "description",              limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "shared_learner_state_key", limit: 255
    t.string   "component_label",          limit: 255
  end

  add_index "plugins", ["plugin_scope_id", "plugin_scope_type"], name: "plugin_scopes", using: :btree

  create_table "portal_publications", force: :cascade do |t|
    t.string   "portal_url",       limit: 255
    t.text     "response",         limit: 65535
    t.boolean  "success"
    t.integer  "publishable_id",   limit: 4
    t.string   "publishable_type", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "publication_hash", limit: 40
    t.integer  "publication_time", limit: 4
    t.text     "sent_data",        limit: 65535
  end

  add_index "portal_publications", ["publishable_id", "publishable_type"], name: "index_portal_publications_on_publishable_id_and_publishable_type", using: :btree

  create_table "project_admins", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "project_admins", ["user_id", "project_id"], name: "index_project_admins_on_user_id_and_project_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.string   "logo_lara",               limit: 255
    t.string   "url",                     limit: 255
    t.text     "footer",                  limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "about",                   limit: 65535
    t.string   "logo_ap",                 limit: 255
    t.string   "project_key",             limit: 255
    t.text     "copyright",               limit: 65535
    t.string   "copyright_image_url",     limit: 255
    t.text     "collaborators",           limit: 65535
    t.string   "funders_image_url",       limit: 255
    t.string   "collaborators_image_url", limit: 255
    t.string   "contact_email",           limit: 255
  end

  add_index "projects", ["project_key"], name: "index_projects_on_project_key", unique: true, using: :btree

  create_table "question_trackers", force: :cascade do |t|
    t.string  "name",                 limit: 255
    t.string  "description",          limit: 255
    t.integer "master_question_id",   limit: 4
    t.string  "master_question_type", limit: 255
    t.integer "user_id",              limit: 4
  end

  create_table "rubrics", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "user_id",             limit: 4
    t.integer  "project_id",          limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "authored_content_id", limit: 4
    t.string   "doc_url",             limit: 255
  end

  create_table "runs", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "run_count",            limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "key",                  limit: 255
    t.integer  "activity_id",          limit: 4
    t.string   "remote_id",            limit: 255
    t.integer  "page_id",              limit: 4
    t.string   "remote_endpoint",      limit: 255
    t.integer  "sequence_id",          limit: 4
    t.integer  "sequence_run_id",      limit: 4
    t.boolean  "is_dirty",                           default: false
    t.integer  "collaboration_run_id", limit: 4
    t.text     "class_info_url",       limit: 65535
    t.string   "context_id",           limit: 255
    t.string   "platform_id",          limit: 255
    t.string   "platform_user_id",     limit: 255
    t.string   "resource_link_id",     limit: 255
    t.integer  "status",               limit: 4,     default: 0
  end

  add_index "runs", ["activity_id"], name: "index_runs_on_activity_id", using: :btree
  add_index "runs", ["collaboration_run_id"], name: "runs_collaboration_idx", using: :btree
  add_index "runs", ["key"], name: "index_runs_on_key", using: :btree
  add_index "runs", ["remote_endpoint"], name: "index_runs_on_remote_endpoint", using: :btree
  add_index "runs", ["sequence_id"], name: "index_runs_on_sequence_id", using: :btree
  add_index "runs", ["sequence_run_id"], name: "index_runs_on_sequence_run_id", using: :btree
  add_index "runs", ["status"], name: "index_runs_on_status", using: :btree
  add_index "runs", ["updated_at"], name: "index_runs_on_updated_at", using: :btree
  add_index "runs", ["user_id", "activity_id"], name: "index_runs_on_user_id_and_activity_id", using: :btree
  add_index "runs", ["user_id", "remote_id", "remote_endpoint"], name: "runs_user_remote_endpt_idx", using: :btree
  add_index "runs", ["user_id"], name: "index_runs_on_user_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.boolean  "show"
    t.string   "layout",              limit: 255
    t.integer  "position",            limit: 4
    t.integer  "interactive_page_id", limit: 4
    t.boolean  "can_collapse_small"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name",                limit: 255
  end

  add_index "sections", ["interactive_page_id", "position"], name: "index_sections_on_interactive_page_id_and_position", using: :btree

  create_table "sequence_runs", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "sequence_id",      limit: 4
    t.string   "remote_id",        limit: 255
    t.string   "remote_endpoint",  limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "key",              limit: 255
    t.string   "context_id",       limit: 255
    t.string   "class_info_url",   limit: 255
    t.string   "platform_id",      limit: 255
    t.string   "platform_user_id", limit: 255
    t.string   "resource_link_id", limit: 255
  end

  add_index "sequence_runs", ["key"], name: "sequence_runs_key_idx", using: :btree
  add_index "sequence_runs", ["sequence_id"], name: "index_sequence_runs_on_sequence_id", using: :btree
  add_index "sequence_runs", ["user_id"], name: "index_sequence_runs_on_user_id", using: :btree

  create_table "sequences", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.text     "description",              limit: 65535
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "user_id",                  limit: 4
    t.integer  "project_id",               limit: 4
    t.text     "logo",                     limit: 65535
    t.string   "publication_status",       limit: 255,   default: "private"
    t.boolean  "is_official",                            default: false
    t.string   "display_title",            limit: 255
    t.string   "thumbnail_url",            limit: 255
    t.text     "abstract",                 limit: 65535
    t.string   "publication_hash",         limit: 40
    t.string   "imported_activity_url",    limit: 255
    t.text     "last_report_service_hash", limit: 65535
    t.string   "background_image",         limit: 255
    t.string   "fixed_width_layout",       limit: 255,   default: "1100px"
    t.boolean  "defunct",                                default: false
    t.string   "migration_status",         limit: 255,   default: "not_migrated"
    t.boolean  "hide_read_aloud",                        default: false
    t.string   "font_size",                limit: 255,   default: "normal"
    t.integer  "layout_override",          limit: 4,     default: 0
    t.boolean  "hide_question_numbers",                  default: false
  end

  add_index "sequences", ["project_id"], name: "index_sequences_on_project_id", using: :btree
  add_index "sequences", ["updated_at"], name: "sequences_updated_at_idx", using: :btree
  add_index "sequences", ["user_id"], name: "index_sequences_on_user_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.text     "value",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "settings", ["key"], name: "index_settings_on_key", using: :btree

  create_table "tracked_questions", force: :cascade do |t|
    t.integer "question_tracker_id", limit: 4
    t.integer "question_id",         limit: 4
    t.string  "question_type",       limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "is_admin",                             default: false
    t.boolean  "is_author",                            default: false
    t.text     "api_key",                limit: 65535
    t.string   "first_name",             limit: 100
    t.string   "last_name",              limit: 100
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "video_interactives", force: :cascade do |t|
    t.string   "poster_url",       limit: 255
    t.text     "caption",          limit: 65535
    t.text     "credit",           limit: 65535
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "width",            limit: 4,     default: 556,            null: false
    t.integer  "height",           limit: 4,     default: 240,            null: false
    t.boolean  "is_hidden",                      default: false
    t.boolean  "is_half_width",                  default: false
    t.string   "migration_status", limit: 255,   default: "not migrated"
  end

  create_table "video_sources", force: :cascade do |t|
    t.string   "url",                  limit: 255, null: false
    t.string   "format",               limit: 255, null: false
    t.integer  "video_interactive_id", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "video_sources", ["video_interactive_id"], name: "index_video_sources_on_video_interactive_id", using: :btree

end
