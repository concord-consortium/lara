class RemoveCRaterAndScoreMapping < ActiveRecord::Migration[5.2]
  def up
    drop_table :c_rater_feedback_items
    drop_table :c_rater_feedback_submissions
    drop_table :c_rater_item_settings
    drop_table :c_rater_score_mappings
  end
  def down
    # c_rater_feedback_items
    create_table :c_rater_feedback_items do |t|
      t.text :answer_text
      t.references :answer, polymorphic: true
      t.string :item_id
      t.string :status
      t.integer :score

      t.text :feedback_text
      t.text :response_info
      t.integer :feedback_submission_id
      t.string :feedback_submission_type
      t.timestamps
    end
    add_index :c_rater_feedback_items, [:answer_id, :answer_type], name: 'c_rat_feed_it_answer_idx'
    add_index :c_rater_feedback_items, [:feedback_submission_id, :feedback_submission_type], name: 'c_rater_feed_item_submission_idx'

    # c_rater_feedback_submissions
    create_table c_rater_feedback_submissions do |t|
      t.integer :usefulness_score
      t.timestamps
      t.integer :interactive_page_id
      t.integer :run_id
      t.integer :collaboration_run_id
      t.integer :base_submission_id
    end
    add_index :c_rater_feedback_submissions, :base_submission_id, name: 'feedback_submissions_base_sub_id_idx'
    add_index :c_rater_feedback_submissions, [:interactive_page_id, :run_id, :created_at], name: 'c_rater_fed_submission_page_run_created_idx'

    # c_rater_item_settings
    rename_table :c_rater_settings, :c_rater_item_settings

    # c_rater_score_mappings
    create_table :c_rater_score_mappings do |t|
      t.text :mapping
      t.timestamps
      t.string :description
      t.integer :user_id
      t.integer :changed_by_id
    end
  end
end
