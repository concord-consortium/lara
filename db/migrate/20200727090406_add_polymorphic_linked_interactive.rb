class AddPolymorphicLinkedInteractive < ActiveRecord::Migration[5.1]

  class MwInteractive < ActiveRecord::Base
  end
  class ManagedInteractive < ActiveRecord::Base
  end

  def up
    add_column :mw_interactives, :linked_interactive_type, :string
    add_column :managed_interactives, :linked_interactive_type, :string

    MwInteractive.where("linked_interactive_id IS NOT NULL").update_all(linked_interactive_type: "MwInteractive")
    ManagedInteractive.where("linked_interactive_id IS NOT NULL").update_all(linked_interactive_type: "ManagedInteractive")
  end

  def down
    remove_column :mw_interactives, :linked_interactive_type
    remove_column :managed_interactives, :linked_interactive_type
  end
end
