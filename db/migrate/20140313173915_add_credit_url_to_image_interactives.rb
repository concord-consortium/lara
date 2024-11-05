class AddCreditUrlToImageInteractives < ActiveRecord::Migration[5.1]
  def change
    add_column :image_interactives, :credit_url, :string
  end
end
