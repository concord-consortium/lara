module FixedWidthLayout
  FIXED_WIDTH_LAYOUT_VALUES = %w(not_enabled ipad_friendly 1100px)
  FIXED_WIDTH_LAYOUT_OPTIONS = {
    'Not Enabled' => 'not_enabled',
    'iPad Friendly' => 'ipad_friendly',
    '1100px' => '1100px'
  }

  def self.included(clazz)
    clazz.class_eval do
      validates :fixed_width_layout, :inclusion => { :in => FIXED_WIDTH_LAYOUT_VALUES }
      default_value_for :fixed_width_layout, 'not_enabled'
      attr_accessible :fixed_width_layout
    end
  end
end
