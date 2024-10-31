class LinkedPageItem < ApplicationRecord

  # attr_accessible :primary_id, :secondary_id, :label

  belongs_to :primary, :class_name => 'PageItem'
  belongs_to :secondary, :class_name => 'PageItem'

  validates :primary_id, presence: true
  validates :secondary_id, presence: true

end
