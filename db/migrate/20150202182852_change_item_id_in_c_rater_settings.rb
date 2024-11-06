class ChangeItemIdInCRaterSettings < ActiveRecord::Migration
  def up
    # Index name too long issue...
    remove_index :c_rater_settings, [:provider_id, :provider_type]
    add_index :c_rater_settings, [:provider_id, :provider_type], name: 'c_rat_set_prov_idx'
    remove_index :c_rater_feedback_items, [:answer_id, :answer_type]
    add_index :c_rater_feedback_items, [:answer_id, :answer_type], name: 'c_rat_feed_it_answer_idx'

    change_column :c_rater_settings, :item_id, :string
    change_column :c_rater_feedback_items, :item_id, :string
  end

  def down
    change_column :c_rater_settings, :item_id, :integer
    change_column :c_rater_feedback_items, :item_id, :integer

    remove_index :c_rater_feedback_items, name: 'c_rat_feed_it_answer_idx'
    add_index :c_rater_feedback_items, [:answer_id, :answer_type]
    remove_index :c_rater_settings, name: 'c_rat_set_prov_idx'
    add_index :c_rater_settings, [:provider_id, :provider_type]
  end
end
