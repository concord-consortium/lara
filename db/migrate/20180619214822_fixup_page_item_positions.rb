class FixupPageItemPositions < ActiveRecord::Migration[5.1]
  class InteractivePage < ApplicationRecord
    has_many :page_items, -> { order(:section, :position) }
  end

  class PageItem < ApplicationRecord
    acts_as_list scope: :interactive_page
    belongs_to :interactive_page
  end


  def up
    InteractivePage.find_each(batch_size: 10) do |page|
      page.page_items.each_with_index do |item,index|
        new_position = index + 1
        next if item.position == new_position
        item.update_column('position', new_position)
      end
    end
  end

  def down
    puts "This migration can not be reversed"
  end
end
