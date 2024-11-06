class AddDescriptionToCRaterScoreMapping < ActiveRecord::Migration
  def change
    add_column :c_rater_score_mappings, :description, :string
  end
end
