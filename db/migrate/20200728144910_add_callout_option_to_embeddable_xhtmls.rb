class AddCalloutOptionToEmbeddableXhtmls < ActiveRecord::Migration[5.1]

  module Embeddable
    class Embeddable::Xhtml < ApplicationRecord
      has_many :page_items, as: :embeddable, dependent: :destroy
      has_many :interactive_pages, through: :page_items
    end

    def self.table_name_prefix
      'embeddable_'
    end
  end

  class InteractivePage < ApplicationRecord
    has_many :page_items, -> { order(:section, :position) }
  end

  class PageItem < ApplicationRecord
    acts_as_list scope: :interactive_page
    belongs_to :interactive_page
    belongs_to :embeddable, polymorphic: true, dependent: :destroy
  end

  def up
    add_column :embeddable_xhtmls, :is_callout, :boolean, default: true

    InteractivePage
      .select("interactive_pages.id")
      .joins("JOIN page_items ON interactive_pages.id = page_items.interactive_page_id
              AND page_items.section = 'header_block'"
            )
      .find_each(batch_size: 1000) do |ip|
        textbox_id = ip.page_items.where(embeddable_type: 'Embeddable::Xhtml', section: 'header_block')
                                  .order(position: :asc)
                                  .pluck(:embeddable_id)
                                  .first
        if !textbox_id.nil?
          Embeddable::Xhtml.where(id: textbox_id).update_all(is_callout: false)
        end
    end
  end

  def down
    remove_column :embeddable_xhtmls, :is_callout
  end
end
