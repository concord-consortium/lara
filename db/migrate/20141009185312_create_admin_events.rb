class CreateAdminEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_events do |t|
      t.string :kind
      t.text :message

      t.timestamps
    end
  end
end
