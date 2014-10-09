class CreateAdminEvents < ActiveRecord::Migration
  def change
    create_table :admin_events do |t|
      t.string :kind
      t.text :message

      t.timestamps
    end
  end
end
