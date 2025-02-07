class Section < ApplicationRecord
  acts_as_list scope: :interactive_page

  belongs_to :interactive_page
  has_many :page_items, -> { order(:position) }, dependent: :destroy

  default_scope{order('position ASC')}

  HEADER_BLOCK = 'header_block'
  INTERACTIVE_BOX = 'interactive_box'
  ASSESSMENT_BLOCK = "assessment_block"
  DEFAULT_SECTION_TITLE = ASSESSMENT_BLOCK
  LAYOUT_FULL_WIDTH="full-width"
  LAYOUT_60_40="60-40"
  LAYOUT_40_60="40-60"
  LAYOUT_70_30="70-30"
  LAYOUT_30_70="30-70"
  LAYOUT_RESPONSIVE="responsive"
  LAYOUT_DFEAULT=LAYOUT_FULL_WIDTH

  LAYOUT_OPTIONS = [
    { name: LAYOUT_FULL_WIDTH,  class_vals: ['section-full-width']},
    { name: LAYOUT_60_40,       class_vals: ['section-60','section-40'] },
    { name: LAYOUT_40_60,       class_vals: ['section-40','section-60'] },
    { name: LAYOUT_70_30,       class_vals: ['section-70','section-30'] },
    { name: LAYOUT_30_70,       class_vals: ['section-30','section-70'] },
    { name: LAYOUT_RESPONSIVE,  class_vals: ['section-responsive'] }
  ]

  EMBEDDABLE_DISPLAY_OPTIONS = ['stacked','carousel']

  DEFAULT_PARAMS = {
    title: DEFAULT_SECTION_TITLE,
    name: nil,
    show: true,
    layout: LAYOUT_DFEAULT,
    can_collapse_small: false
  }

  def css_class_for_item_index(index)
    options = LAYOUT_OPTIONS.find { |l| l[:name] == self.layout }
    if options
      layouts = options[:class_vals]
      layout_index = index % layouts.length
      layouts[layout_index]
    else
      puts "error: no classes for layout #{self.layout}"
      'unknown'
    end
  end

  def to_hash
    {
      title: title,
      name: name,
      show: show,
      layout: layout,
      position: position,
      interactive_page_id: interactive_page_id,
      can_collapse_small: can_collapse_small
    }
  end

  def export
    helper = LaraSerializationHelper.new
    {
      title: title,
      name: name,
      is_hidden: !show,
      layout: layout,
      secondary_column_collapsible: can_collapse_small,
      secondary_column_display_mode: "stacked", # TODO: Add display mode
      embeddables: page_items.map do |page_item|
        page_item.export(helper)
      end
    }
  end

  def embeddables
    page_items.map(&:embeddable)
  end

  def duplicate(helper=nil, new_page_id=nil)
    helper = LaraDuplicationHelper.new if helper.nil?
    new_section = Section.new(to_hash)
    if new_page_id.nil?
      new_section.position = new_section.position + 1
    else
      new_section.interactive_page_id = new_page_id
    end
    Section.transaction do
      new_section.save!(validate: false)

      # Now, add them to the page and resolve some dependencies between embeddables.
      page_items.each do |item|
        embed = item.embeddable
        emb_copy = helper.get_copy(embed)

        if embed.respond_to?(:embeddable=) && embed.embeddable
          emb_copy.embeddable = helper.get_copy(embed.embeddable)
        end
        if embed.respond_to?(:interactive=) && embed.interactive
          emb_copy.interactive = helper.get_copy(embed.interactive)
        end
        if embed.respond_to?(:linked_interactive=) && embed.linked_interactive
          emb_copy.linked_interactive = helper.get_copy(embed.linked_interactive)
        end
        emb_copy.save!(validate: false)
        new_item = new_section.page_items.create!(
          embeddable: emb_copy,
          position: item.position,
          column: item.column
        )
        new_item.move_lower
      end

      # with the embeddables added link any interactive links
      embeddables.each do |embed|
        if embed.respond_to?(:primary_linked_items)
          embed.primary_linked_items.each do |pli|
            primary = helper.get_copy(embed)
            secondary = helper.get_copy(pli.secondary.embeddable)
            # If the secondary embeddable is in a different section, it won't be copied. So in that
            # case, the new primary embeddable references the original secondary embeddable.
            secondary_page_item = secondary.page_item ? secondary.page_item : pli.secondary.embeddable.page_item
            if primary && secondary_page_item
              lpi = LinkedPageItem.new(primary_id: primary.page_item.id, secondary_id: secondary_page_item.id, label: pli.label)
              lpi.save!(validate: false)
            end
          end
        end
      end
    end
    new_section.reload
  end

end
