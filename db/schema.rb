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

ActiveRecord::Schema.define(:version => 20130401185220) do

  create_table "activity_responses", :force => true do |t|
    t.string   "key",         :null => false
    t.text     "responses"
    t.integer  "activity_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "last_page"
  end

  create_table "embeddable_multiple_choice_choices", :force => true do |t|
    t.integer  "multiple_choice_id"
    t.text     "choice"
    t.boolean  "is_correct"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "prompt"
  end

  create_table "embeddable_multiple_choices", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "embeddable_open_responses", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "embeddable_xhtmls", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.integer  "user_id"
    t.integer  "position"
    t.text     "text"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "offerings_count"
    t.text     "sidebar"
    t.boolean  "show_introduction",       :default => false
    t.boolean  "show_sidebar",            :default => false
    t.boolean  "show_interactive",        :default => false
    t.boolean  "show_info_assessment",    :default => false
    t.string   "workflow_state"
  end

  add_index "interactive_pages", ["lightweight_activity_id", "position"], :name => "altered_interactive_pages_by_activity_idx"
  add_index "interactive_pages", ["user_id"], :name => "altered_interactive_pages_user_idx"

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
  end

  add_index "lightweight_activities", ["publication_status"], :name => "altered_lightweight_activities_publication_status_idx"
  add_index "lightweight_activities", ["user_id"], :name => "altered_lightweight_activities_user_idx"

  create_table "mw_interactives", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.float    "width",         :default => 60.0
    t.integer  "native_width"
    t.integer  "native_height"
    t.boolean  "fullwidth",     :default => false
  end

  add_index "mw_interactives", ["user_id"], :name => "mw_interactives_user_idx"

  create_table "page_items", :force => true do |t|
    t.integer  "interactive_page_id"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
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
    t.string   "authentication_token"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_admin",               :default => false
    t.boolean  "is_author",              :default => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
