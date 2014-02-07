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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140124152812) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "index"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["uid", "provider"], :name => "index_authentications_on_uid_and_provider", :unique => true
  add_index "authentications", ["user_id", "provider"], :name => "index_authentications_on_user_id_and_provider", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "embeddable_image_question_answers", :force => true do |t|
    t.integer  "run_id"
    t.text     "answer_text"
    t.string   "image_url"
    t.integer  "image_question_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "annotation"
    t.string   "annotated_image_url"
    t.boolean  "is_dirty",            :default => false
  end

  add_index "embeddable_image_question_answers", ["image_question_id"], :name => "index_embeddable_image_question_answers_on_image_question_id"
  add_index "embeddable_image_question_answers", ["run_id", "image_question_id"], :name => "index_multiple_choice_answers_on_run_and_question"
  add_index "embeddable_image_question_answers", ["run_id"], :name => "index_embeddable_image_question_answers_on_run_id"

  create_table "embeddable_image_questions", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "bg_source",      :default => "Shutterbug"
    t.string   "bg_url"
    t.text     "drawing_prompt"
  end

  create_table "embeddable_multiple_choice_answers", :force => true do |t|
    t.integer  "run_id"
    t.integer  "multiple_choice_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_dirty",           :default => false
  end

  add_index "embeddable_multiple_choice_answers", ["multiple_choice_id"], :name => "index_embeddable_multiple_choice_answers_on_multiple_choice_id"
  add_index "embeddable_multiple_choice_answers", ["run_id"], :name => "index_embeddable_multiple_choice_answers_on_run_id"

  create_table "embeddable_multiple_choice_choices", :force => true do |t|
    t.integer  "multiple_choice_id"
    t.text     "choice"
    t.boolean  "is_correct"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "prompt"
  end

  add_index "embeddable_multiple_choice_choices", ["multiple_choice_id"], :name => "index_embeddable_multiple_choice_choices_on_multiple_choice_id"

  create_table "embeddable_multiple_choices", :force => true do |t|
    t.string   "name"
    t.text     "prompt",              :default => "Why does ..."
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.boolean  "custom",              :default => false
    t.boolean  "enable_check_answer", :default => true
    t.boolean  "multi_answer",        :default => false
    t.boolean  "show_as_menu",        :default => false
  end

  create_table "embeddable_open_response_answers", :force => true do |t|
    t.text     "answer_text"
    t.integer  "run_id"
    t.integer  "open_response_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_dirty",         :default => false
  end

  add_index "embeddable_open_response_answers", ["open_response_id"], :name => "index_embeddable_open_response_answers_on_open_response_id"
  add_index "embeddable_open_response_answers", ["run_id", "open_response_id"], :name => "index_open_response_answers_on_run_and_question"
  add_index "embeddable_open_response_answers", ["run_id"], :name => "index_embeddable_open_response_answers_on_run_id"

  create_table "embeddable_open_responses", :force => true do |t|
    t.string   "name"
    t.text     "prompt",     :default => "Why does ..."
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "embeddable_xhtmls", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "image_interactives", :force => true do |t|
    t.string   "url"
    t.text     "caption"
    t.text     "credit"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "show_lightbox", :default => true
  end

  create_table "interactive_items", :force => true do |t|
    t.integer  "interactive_page_id"
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "interactive_items", ["interactive_id", "interactive_type"], :name => "interactive_items_interactive_idx"
  add_index "interactive_items", ["interactive_page_id", "position"], :name => "interactive_items_by_page_idx"

  create_table "interactive_pages", :force => true do |t|
    t.string   "name"
    t.integer  "lightweight_activity_id"
    t.integer  "position"
    t.text     "text"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "sidebar"
    t.boolean  "show_introduction",       :default => false
    t.boolean  "show_sidebar",            :default => false
    t.boolean  "show_interactive",        :default => false
    t.boolean  "show_info_assessment",    :default => false
    t.string   "workflow_state"
    t.string   "layout",                  :default => "l-6040"
    t.string   "embeddable_display_mode", :default => "stacked"
  end

  add_index "interactive_pages", ["lightweight_activity_id", "position"], :name => "interactive_pages_by_activity_idx"

  create_table "interactive_run_states", :force => true do |t|
    t.integer  "interactive_id"
    t.string   "interactive_type"
    t.integer  "run_id"
    t.text     "raw_data"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "learner_url"
  end

  create_table "lightweight_activities", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "publication_status", :default => "draft"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "offerings_count"
    t.text     "related"
    t.text     "description"
    t.integer  "changed_by_id"
    t.boolean  "is_official",        :default => false
    t.integer  "time_to_complete"
    t.boolean  "is_locked",          :default => false
    t.text     "notes"
    t.string   "thumbnail_url"
    t.integer  "theme_id"
    t.integer  "project_id"
  end

  add_index "lightweight_activities", ["changed_by_id"], :name => "index_lightweight_activities_on_changed_by_id"
  add_index "lightweight_activities", ["project_id"], :name => "index_lightweight_activities_on_project_id"
  add_index "lightweight_activities", ["publication_status"], :name => "lightweight_activities_publication_status_idx"
  add_index "lightweight_activities", ["theme_id"], :name => "index_lightweight_activities_on_theme_id"
  add_index "lightweight_activities", ["user_id"], :name => "lightweight_activities_user_idx"

  create_table "lightweight_activities_sequences", :force => true do |t|
    t.integer  "lightweight_activity_id", :default => 1, :null => false
    t.integer  "sequence_id",             :default => 1, :null => false
    t.integer  "position",                :default => 1
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "lightweight_activities_sequences", ["lightweight_activity_id"], :name => "index_activities_sequence_join_by_activity"
  add_index "lightweight_activities_sequences", ["sequence_id"], :name => "index_activities_sequence_join_by_sequence"

  create_table "mc_answer_choices", :id => false, :force => true do |t|
    t.integer "answer_id"
    t.integer "choice_id"
  end

  add_index "mc_answer_choices", ["answer_id", "choice_id"], :name => "index_mc_answer_choices_on_answer_id_and_choice_id"
  add_index "mc_answer_choices", ["choice_id", "answer_id"], :name => "index_mc_answer_choices_on_choice_id_and_answer_id"

  create_table "mw_interactives", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "native_width"
    t.integer  "native_height"
    t.boolean  "save_state",    :default => false
  end

  create_table "page_items", :force => true do |t|
    t.integer  "interactive_page_id"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "page_items", ["embeddable_id", "embeddable_type"], :name => "index_page_items_on_embeddable_id_and_embeddable_type"
  add_index "page_items", ["interactive_page_id"], :name => "index_page_items_on_interactive_page_id"

  create_table "portal_publications", :force => true do |t|
    t.string   "portal_url"
    t.string   "response"
    t.boolean  "success"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.string   "logo"
    t.string   "url"
    t.text     "footer"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "theme_id"
  end

  add_index "projects", ["theme_id"], :name => "index_projects_on_theme_id"

  create_table "runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "run_count"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "key"
    t.integer  "activity_id"
    t.string   "remote_id"
    t.integer  "page_id",         :default => 0
    t.string   "remote_endpoint"
    t.integer  "sequence_id"
    t.integer  "sequence_run_id"
    t.boolean  "is_dirty",        :default => false
  end

  add_index "runs", ["activity_id"], :name => "index_runs_on_activity_id"
  add_index "runs", ["key"], :name => "index_runs_on_key"
  add_index "runs", ["remote_endpoint"], :name => "index_runs_on_remote_endpoint"
  add_index "runs", ["sequence_id"], :name => "index_runs_on_sequence_id"
  add_index "runs", ["sequence_run_id"], :name => "index_runs_on_sequence_run_id"
  add_index "runs", ["user_id", "activity_id"], :name => "index_runs_on_user_id_and_activity_id"
  add_index "runs", ["user_id", "remote_id", "remote_endpoint"], :name => "index_runs_on_user_id_and_remote_id_and_remote_endpoint"
  add_index "runs", ["user_id"], :name => "index_runs_on_user_id"

  create_table "sequence_runs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sequence_id"
    t.string   "remote_id"
    t.string   "remote_endpoint"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sequence_runs", ["sequence_id"], :name => "index_sequence_runs_on_sequence_id"
  add_index "sequence_runs", ["user_id"], :name => "index_sequence_runs_on_user_id"

  create_table "sequences", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "user_id"
    t.integer  "theme_id"
    t.integer  "project_id"
    t.text     "logo"
    t.string   "publication_status", :default => "draft"
    t.boolean  "is_official",        :default => false
    t.string   "display_title"
  end

  add_index "sequences", ["project_id"], :name => "index_sequences_on_project_id"
  add_index "sequences", ["theme_id"], :name => "index_sequences_on_theme_id"
  add_index "sequences", ["user_id"], :name => "index_sequences_on_user_id"

  create_table "themes", :force => true do |t|
    t.string   "name"
    t.string   "css_file"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_admin",               :default => false
    t.boolean  "is_author",              :default => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "video_interactives", :force => true do |t|
    t.string   "poster_url"
    t.text     "caption"
    t.text     "credit"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "width",      :default => 556, :null => false
    t.integer  "height",     :default => 240, :null => false
  end

  create_table "video_sources", :force => true do |t|
    t.string   "url",                  :null => false
    t.string   "format",               :null => false
    t.integer  "video_interactive_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "video_sources", ["video_interactive_id"], :name => "index_video_sources_on_video_interactive_id"

end
