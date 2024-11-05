class CopyPageIntroToNewHeaderTextbox < ActiveRecord::Migration[5.1]
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
    # Only include pages that don't already have a header_block page item
    # And have non null text
    InteractivePage
      .select("interactive_pages.id, text, show_header, show_introduction")
      .joins('LEFT OUTER JOIN page_items ON interactive_pages.id = page_items.interactive_page_id AND page_items.section = "header_block"')
      .where('page_items.id is null AND interactive_pages.text is not null')
      .find_each(batch_size: 1000) do |ip|
        ip.show_header = ip.show_introduction
        ip.save
        textbox = Embeddable::Xhtml.create(
                                           name: '',
                                           content: ip.text,
                                           is_full_width: true
                                          )
        PageItem.create(
                        interactive_page_id: ip.id,
                        embeddable_id: textbox.id,
                        embeddable_type: 'Embeddable::Xhtml',
                        position: 1,
                        section: 'header_block'
                       )
    end
  end

  def down
    InteractivePage.find_each(batch_size: 10) do |ip|
      PageItem.where(interactive_page_id: ip.id, section: 'header_block').order(:position).each do |pi|
        if pi.embeddable_type == 'Embeddable::Xhtml'
          textbox = Embeddable::Xhtml.where(id: pi.embeddable_id).first
          if ip.text.nil?
            ip.text = textbox.content
            pi.destroy()
          end
        end
      end
      ip.show_introduction = ip.show_header
      ip.save
    end
  end
end
