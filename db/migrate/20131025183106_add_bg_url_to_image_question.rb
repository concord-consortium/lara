class AddBgUrlToImageQuestion < ActiveRecord::Migration
  def change
    add_column :embeddable_image_questions, :bg_url, :string, null: true
  end
end
