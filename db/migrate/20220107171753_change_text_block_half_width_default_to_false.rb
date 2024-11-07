class ChangeTextBlockHalfWidthDefaultToFalse < ActiveRecord::Migration[5.1]
  class Embeddable::Xhtml < ApplicationRecord
  end

  def up
    change_column_default :embeddable_xhtmls, :is_half_width, false
  end

  def down
    change_column_default :embeddable_xhtmls, :is_half_width, true
  end
end
