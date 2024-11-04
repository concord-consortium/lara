module FixedWidthLayout
  FIXED_WIDTH_LAYOUT_VALUES = %w(ipad_friendly 1100px)
  FIXED_WIDTH_LAYOUT_OPTIONS = {
    'Standard (1100px)' => '1100px',
    'iPad Friendly (960px)' => 'ipad_friendly'
  }

  def self.included(clazz)
    clazz.class_eval do
      validates :fixed_width_layout, inclusion: { in: FIXED_WIDTH_LAYOUT_VALUES }
      default_value_for :fixed_width_layout, '1100px'
    end
  end
end
