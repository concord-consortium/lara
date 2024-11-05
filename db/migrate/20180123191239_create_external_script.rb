class CreateExternalScript < ActiveRecord::Migration[5.1]

  def up
    create_table :embeddable_external_scripts do |t|
      t.belongs_to :approved_script, index: true
      t.text       :configuration
      t.text       :description
      t.timestamps
    end
  end

  def down
    drop_table :embeddable_external_scripts
  end

end
