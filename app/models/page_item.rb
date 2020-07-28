class PageItem < ActiveRecord::Base
  attr_accessible :interactive_page, :position, :section, :embeddable
  acts_as_list :scope => :interactive_page

  belongs_to :interactive_page
  belongs_to :embeddable, :polymorphic => true, :dependent => :destroy

  has_many :primary_linked_items, :foreign_key => :primary_id, :class_name => LinkedPageItem, :dependent => :destroy
  has_many :secondary_linked_items, :foreign_key => :secondary_id, :class_name => LinkedPageItem, :dependent => :destroy

  def toggle_hideshow_embeddable
    embeddable.is_hidden = !embeddable.is_hidden
    embeddable.save
  end

end
