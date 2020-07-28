class AddCalloutOptionToEmbeddableXhtmls < ActiveRecord::Migration
  def change
    add_column :embeddable_xhtmls, :is_callout, :boolean, :default => false
  end
end
