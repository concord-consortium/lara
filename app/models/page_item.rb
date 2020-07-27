class PageItem < ActiveRecord::Base
  attr_accessible :interactive_page, :position, :section, :embeddable
  acts_as_list :scope => :interactive_page

  belongs_to :interactive_page
  belongs_to :embeddable, :polymorphic => true, :dependent => :destroy

  # can't use has_many with destroy here as the PageItem.id may be in two different columns in the LinkedPageItem
  before_destroy :destroy_linked_page_items

  def toggle_hideshow_embeddable
    embeddable.is_hidden = !embeddable.is_hidden
    embeddable.save
  end

  def primary_linked_items
    LinkedPageItem.where(primary_id: self.id)
  end

  def secondary_linked_items
    LinkedPageItem.where(secondary_id: self.id)
  end

  private

  def destroy_linked_page_items
    self.primary_linked_items.delete_all
    self.secondary_linked_items.delete_all
  end

end
