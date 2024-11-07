class AddBgUrlToImageQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_questions, :bg_url, :string, null: true
  end
end
