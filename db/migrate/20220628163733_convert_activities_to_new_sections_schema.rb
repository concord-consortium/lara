class ConvertActivitiesToNewSectionsSchema < ActiveRecord::Migration
  class InteractivePage < ApplicationRecord
    has_many :sections, -> { include(:page_items).order(:position) }
    has_many :page_items
  end

  class PageItem < ApplicationRecord

  end

  class Section < ApplicationRecord
    # attr_accessible :interactive_page_id, :layout, :position, :show
    belongs_to :interactive_page
    has_many :page_items, -> { order(:position) }, dependent: :destroy
  end

  def create_section(page_id, layout, position, show)
    Section.create(
      :interactive_page_id => page_id,
      :layout => layout,
      :position => position,
      :show => show
    )
  end

  def add_items_to_section(items, section_id, column)
    section_position = 1
    items.each do |item|
      item.section_id = section_id
      item.column = column
      item.section_position = section_position
      item.save(:validate => false)
      section_position += 1
    end
  end

  def up
    layout_map = {
      "l-full-width" => "full-width",
      "l-responsive" => "responsive-2-columns",
      "l-6040" => "40-60",
      "r-4060" => "60-40",
      "l-7030" => "30-70",
      "r-3070" => "70-30",
    }
    pages_to_process = InteractivePage.count
    pages_processed = 0
    puts "There are #{pages_to_process} pages to process."
    pages = InteractivePage.includes(:page_items)
    pages.find_each(batch_size: 100) do |page|
      InteractivePage.transaction do
        section_count = 0
        header_block_items = []
        primary_block_items = []
        secondary_block_items = []
        show_interactive = page.show_interactive
        show_info_assessment = page.show_info_assessment
        show_header = page.show_header
        page_items = page.page_items
        page_items.each do |item|
          old_section = item.old_section
          if old_section == "header_block"
            header_block_items << item
          elsif old_section == "interactive_box"
            primary_block_items << item
          elsif
            secondary_block_items << item
          end
        end

        if header_block_items.length > 0
          section_count += 1
          header_block_section = create_section(page.id, "full-width", section_count, show_header)
          add_items_to_section(header_block_items, header_block_section.id, "primary")
        end

        if primary_block_items.length > 0 || secondary_block_items.length > 0
          section_count += 1
          section_layout = layout_map[page.layout]
          if show_interactive && show_info_assessment
            # put all items in the same section
            assessment_section = create_section(page.id, section_layout, section_count, true)
            add_items_to_section(primary_block_items, assessment_section.id, "primary")
            secondary_items_column = section_layout != "full-width" ? "secondary" : "primary"
            add_items_to_section(secondary_block_items, assessment_section.id, secondary_items_column)
          elsif show_interactive
            assessment_section = create_section(page.id, section_layout, section_count, true)
            add_items_to_section(primary_block_items, assessment_section.id, "primary")
            # create a hidden section for any secondary items that may exist
            if secondary_block_items.length > 0
              section_count += 1
              hidden_assessment_section = create_section(page.id, section_layout, section_count, false)
              add_items_to_section(secondary_block_items, hidden_assessment_section.id, "primary")
            end
          elsif show_info_assessment
            assessment_section = create_section(page.id, section_layout, section_count, true)
            add_items_to_section(secondary_block_items, assessment_section.id, "primary")
            # create a hidden section for any primary items that may exist
            if primary_block_items.length > 0
              section_count += 1
              hidden_assessment_section = create_section(page.id, section_layout, section_count, false)
              add_items_to_section(primary_block_items, hidden_assessment_section.id, "primary")
            end
          else
            # put any items that may exist into a hidden section
            assessment_section = create_section(page.id, section_layout, section_count, false)
            if primary_block_items.length > 0
              add_items_to_section(primary_block_items, assessment_section.id, "primary")
            end
            secondary_items_column = section_layout != "full-width" ? "secondary" : "primary"
            if secondary_block_items.length > 0
              add_items_to_section(secondary_block_items, assessment_section.id, secondary_items_column)
            end
          end
        end
        pages_processed += 1
        if pages_processed % 100 == 0
          puts "Processed #{pages_processed} of #{pages_to_process} pages."
        end
      end
    end
    puts "Processed #{pages_processed} of #{pages_to_process} pages."
  end

  def down
    # Reverting may not be possible because there isn't a way to know for sure what old section items belong in
  end
end
