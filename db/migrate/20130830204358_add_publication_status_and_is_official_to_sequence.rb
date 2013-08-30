class AddPublicationStatusAndIsOfficialToSequence < ActiveRecord::Migration
  def change
    add_column :sequences, :publication_status, :string, :default => 'draft'
    add_column :sequences, :is_official, :boolean, :default => false
  end
end
