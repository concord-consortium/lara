class CopyPageIntroToNewHeaderTextbox < ActiveRecord::Migration
  module Embeddable
    class Embeddable::Xhtml < ActiveRecord::Base
      attr_accessible :name, :content, :is_hidden, :is_full_width
      has_many :page_items, :as => :embeddable, :dependent => :destroy
      has_many :interactive_pages, :through => :page_items
    end

    def self.table_name_prefix
      'embeddable_'
    end
  end

  class InteractivePage < ActiveRecord::Base
    has_many :page_items, :order => [:section, :position]
  end

  class PageItem < ActiveRecord::Base
    attr_accessible :interactive_page, :position, :section, :embeddable,
                    :interactive_page_id, :embeddable_id, :embeddable_type
    acts_as_list :scope => :interactive_page
    belongs_to :interactive_page
    belongs_to :embeddable, :polymorphic => true, dependent: :destroy
  end

  def up
    InteractivePage.find_each(batch_size: 10) do |ip|
      if ip.text.present?
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
  end

  def down
    InteractivePage.find_each(batch_size: 10) do |ip|
      PageItem.where(interactive_page_id: ip.id, section: 'header_block').order(:position).each do |pi|
        if pi.embeddable_type == 'Embeddable::Xhtml'
          textbox = Embeddable::Xhtml.where(id: pi.embeddable_id).first
          if ip.text.nil?
            ip.text = textbox.content
            textbox.destroy()
          end
        end
      end
      ip.show_introduction = ip.show_header
      ip.save
    end
  end
end
