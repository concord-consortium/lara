class AddBackgroundImageToActivitiesAndSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :background_image, :string
    add_column :sequences, :background_image, :string
  end
end
