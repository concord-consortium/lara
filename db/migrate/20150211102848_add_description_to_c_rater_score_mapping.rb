class AddDescriptionToCRaterScoreMapping < ActiveRecord::Migration[5.1]
  def change
    add_column :c_rater_score_mappings, :description, :string
  end
end
