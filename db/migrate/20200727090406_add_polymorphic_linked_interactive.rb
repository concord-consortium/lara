class AddPolymorphicLinkedInteractive < ActiveRecord::Migration
  def up
    add_column :mw_interactives, :linked_interactive_type, :string
    add_column :managed_interactives, :linked_interactive_type, :string

    MwInteractive.where("linked_interactive_id IS NOT NULL").find_in_batches(batch_size: 100) do |batch|
      batch.each do |mw_interactive|
        mw_interactive.linked_interactive_type = "MwInteractive"
        mw_interactive.save!
      end
    end

    ManagedInteractive.where("linked_interactive_id IS NOT NULL").find_in_batches(batch_size: 100) do |batch|
      batch.each do |managed_interactive|
        managed_interactive.linked_interactive_type = "ManagedInteractive"
        managed_interactive.save!
      end
    end
  end

  def down
    remove_column :mw_interactives, :linked_interactive_type
    remove_column :managed_interactives, :linked_interactive_type
  end
end
