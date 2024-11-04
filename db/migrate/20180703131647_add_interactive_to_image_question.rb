module Embeddable
  InteractiveTypes = {
    MwInteractive    => "Iframe Interactive",
    ImageInteractive => "Image",
    VideoInteractive => "Video"
  }

  def self.is_interactive?(e)
    InteractiveTypes.keys.include?(e.class)
  end

  def self.table_name_prefix
    'embeddable_'
  end

  class ImageQuestion < ApplicationRecord
    has_many :page_items, as: :embeddable, dependent: :destroy
    has_many :interactive_pages, through: :page_items
  end
end

class InteractivePage < ApplicationRecord
  has_many :page_items, -> { order(:section, :position) }

  def embeddables
    page_items.collect{ |qi| qi.embeddable }
  end

  def interactives
    embeddables.select{ |e| Embeddable::is_interactive?(e) }
  end

  def visible_interactives
    interactives.select{ |e| !e.is_hidden }
  end
end

class PageItem < ApplicationRecord
  acts_as_list scope: :interactive_page
  belongs_to :interactive_page

  belongs_to :embeddable, polymorphic: true, dependent: :destroy
end

class AddInteractiveToImageQuestion < ActiveRecord::Migration
  def up
    add_column :embeddable_image_questions, :interactive_id, :integer
    add_column :embeddable_image_questions, :interactive_type, :string

    Embeddable::ImageQuestion.find_each(batch_size: 10) do |iq|
      # Previously, image question was always referring the first interactive on the page.
      # Follow this logic to pick the right interactive and set it explicitly using new columns.
      page = iq.interactive_pages.first
      interactive = page && page.visible_interactives.first
      if interactive
        # update_column shouldn't trigger any callbacks. Safer than iq.interactive = interactive.
        iq.update_column('interactive_id', interactive.id)
        iq.update_column('interactive_type', interactive.class.to_s)
      end
    end
  end

  def down
    remove_column :embeddable_image_questions, :interactive_id
    remove_column :embeddable_image_questions, :interactive_type
  end
end
