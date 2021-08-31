class PageItem < ActiveRecord::Base
  attr_accessible :section, :position, :section, :embeddable
  acts_as_list :scope => :section

  belongs_to :section
  belongs_to :embeddable, :polymorphic => true, :dependent => :destroy

  has_many :primary_linked_items, :foreign_key => :primary_id, :class_name => LinkedPageItem, :dependent => :destroy
  has_many :secondary_linked_items, :foreign_key => :secondary_id, :class_name => LinkedPageItem, :dependent => :destroy
  has_one :interactive_page, through: :section

  default_scope order('position ASC')
  def toggle_hideshow_embeddable
    embeddable.is_hidden = !embeddable.is_hidden
    embeddable.save
  end

end
