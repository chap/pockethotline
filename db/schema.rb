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

ActiveRecord::Schema.define(:version => 20120930175450) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin_only", :default => false, :null => false
  end

  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "auto_tweets", :force => true do |t|
    t.text     "body"
    t.datetime "last_tweeted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "callers", :force => true do |t|
    t.string   "from_phone"
    t.string   "city"
    t.string   "from_city"
    t.string   "zip"
    t.string   "state"
    t.string   "from_state"
    t.string   "phone"
    t.string   "from_zip"
    t.string   "country"
    t.string   "from_country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "blocked",      :default => false, :null => false
  end

  create_table "calls", :force => true do |t|
    t.string   "twilio_id"
    t.integer  "length"
    t.integer  "caller_id"
    t.integer  "operator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "answered_at"
    t.string   "twilio_recording_url"
    t.integer  "recording_duration"
    t.string   "forwarded_to"
    t.string   "token"
    t.datetime "sms_caller_for_review_at"
  end

  add_index "calls", ["operator_id"], :name => "index_calls_on_operator_id"
  add_index "calls", ["token"], :name => "index_calls_on_token"

  create_table "calls_sponsors", :id => false, :force => true do |t|
    t.integer "call_id"
    t.integer "sponsor_id"
  end

  add_index "calls_sponsors", ["call_id"], :name => "index_calls_sponsors_on_call_id"
  add_index "calls_sponsors", ["sponsor_id"], :name => "index_calls_sponsors_on_sponsor_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["activity_id"], :name => "index_comments_on_activity_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oncall_schedules", :force => true do |t|
    t.integer  "user_id"
    t.integer  "wday"
    t.string   "start_time"
    t.string   "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outgoing_calls", :force => true do |t|
    t.integer  "call_id"
    t.integer  "operator_id"
    t.string   "twilio_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outgoing_calls", ["call_id"], :name => "index_outgoing_calls_on_call_id"
  add_index "outgoing_calls", ["operator_id"], :name => "index_outgoing_calls_on_operator_id"

  create_table "reviews", :force => true do |t|
    t.integer  "call_id"
    t.string   "name"
    t.string   "email"
    t.string   "twitter"
    t.text     "question"
    t.text     "answer"
    t.string   "happiness"
    t.datetime "tweeted_at"
    t.datetime "sms_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",      :default => true, :null => false
  end

  add_index "reviews", ["call_id"], :name => "index_review_on_call_id"

  create_table "sponsors", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.boolean  "newsletter_emails",                                :default => true,  :null => false
    t.boolean  "need_help_emails",                                 :default => false, :null => false
    t.boolean  "default",                                          :default => false, :null => false
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "amount",             :precision => 8, :scale => 2, :default => 20.0
    t.string   "stripe_token"
    t.string   "stripe_customer_id"
    t.boolean  "successful",                                       :default => false, :null => false
    t.text     "stripe_response"
    t.decimal  "fee",                :precision => 8, :scale => 2
    t.integer  "minutes_purchased"
    t.integer  "minutes_remaining"
    t.text     "url"
    t.string   "token"
    t.string   "auth_token"
    t.string   "card_type"
    t.string   "last_numbers"
    t.string   "stripe_charge_id"
    t.text     "name"
  end

  add_index "sponsors", ["user_id"], :name => "index_sponsors_on_user_id"

  create_table "status_updates", :force => true do |t|
    t.integer  "user_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "status_updates", ["user_id"], :name => "index_status_updates_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password_hash"
    t.string   "phone"
    t.boolean  "on_call",                                  :default => false, :null => false
    t.boolean  "admin",                                    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.datetime "deleted_at"
    t.text     "bio"
    t.string   "twitter"
    t.boolean  "pending_approval",                         :default => false, :null => false
    t.boolean  "schedule_emails",                          :default => true,  :null => false
    t.boolean  "newsletter_emails",                        :default => true,  :null => false
    t.boolean  "volunteers_first_availability_emails",     :default => true,  :null => false
    t.datetime "admins_notified_of_first_availability_at"
  end

  add_index "users", ["deleted_at"], :name => "index_users_on_deleted_at"
end
