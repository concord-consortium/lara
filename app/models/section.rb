class Section < ActiveRecord::Base
  attr_accessible :title, :position, :show, :layout, :interactive_page, :interactive_page_id
  acts_as_list :scope => :interactive_page

  belongs_to :interactive_page
  has_many :page_items, :dependent => :destroy

  HEADER_BLOCK = 'header_block'
  INTERACTIVE_BOX = 'interactive_box'

  LAYOUT_FULL_WIDHT="Full Width"
  LAYOUT_60_40="60-40"
  LAYOUT_40_60="40-60"
  LAYOUT_70_30="70-30"
  LAYOUT_30_70="30_70"
  LAYOUT_RESPONSIVE="Responsive"
  LAYOUT_DFEAULT=LAYOUT_FULL_WIDTH

  LAYOUT_OPTIONS = [
    { :name => LAYOUT_FULL_WIDHT, :class_val => 'l-full-width' },
    { :name => LAYOUT_60_40,      :class_val => 'l-6040' },
    { :name => LAYOUT_40_60,      :class_val => 'l-7030' },
    { :name => LAYOUT_70_30,      :class_val => 'r-4060' },
    { :name => LAYOUT_30_70,      :class_val => 'r-3070' },
    { :name => LAYOUT_RESPONSIVE, :class_val => 'l-responsive' }
  ]

  EMBEDDABLE_DISPLAY_OPTIONS = ['stacked','carousel']

  DEFAULT_PARAMS = {
    title: "Default section",
    show: true,
    layout: DEFAULT_LAYOUT,
    can_collapse_small: false
  }

end
