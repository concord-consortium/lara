class AddCreditUrlToImageInteractives < ActiveRecord::Migration
  def change
    add_column :image_interactives, :credit_url, :string
  end
end
