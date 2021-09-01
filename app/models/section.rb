class Section < ActiveRecord::Base
  attr_accessible :title, :position, :show, :layout, :interactive_page, :interactive_page_id, :can_collapse_small
  acts_as_list scope: :interactive_page

  belongs_to :interactive_page
  has_many :page_items, order: :position, dependent: :destroy

  default_scope order('position ASC')

  HEADER_BLOCK = 'header_block'
  INTERACTIVE_BOX = 'interactive_box'
  DEFAULT_SECTION_TITLE = "main"

  LAYOUT_FULL_WIDTH="Full Width"
  LAYOUT_60_40="60-40"
  LAYOUT_40_60="40-60"
  LAYOUT_70_30="70-30"
  LAYOUT_30_70="30_70"
  LAYOUT_RESPONSIVE="Responsive"
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
      'unkown'
    end
  end

end
