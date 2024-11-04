class AddLegacyGlossaryResourceId < ActiveRecord::Migration
  def change
    add_column :glossaries, :legacy_glossary_resource_id, :string, null: true
  end
end
