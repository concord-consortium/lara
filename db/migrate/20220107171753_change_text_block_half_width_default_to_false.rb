class ChangeTextBlockHalfWidthDefaultToFalse < ActiveRecord::Migration
  class Embeddable::Xhtml < ActiveRecord::Base
  end

  def up
    change_column_default :embeddable_xhtmls, :is_half_width, false
  end

  def down
    change_column_default :embeddable_xhtmls, :is_half_width, true
  end
end
