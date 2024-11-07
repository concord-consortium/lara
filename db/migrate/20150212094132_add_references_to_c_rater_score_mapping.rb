class AddReferencesToCRaterScoreMapping < ActiveRecord::Migration[5.1]
  def change
    add_column :c_rater_score_mappings, :user_id, :integer
    add_column :c_rater_score_mappings, :changed_by_id, :integer
  end
end
