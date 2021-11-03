class PageItem < ActiveRecord::Base
  attr_accessible :section, :position, :embeddable, :column
  acts_as_list :scope => :section

  belongs_to :section
  belongs_to :embeddable, :polymorphic => true, :dependent => :destroy

  has_many :primary_linked_items, :foreign_key => :primary_id, :class_name => LinkedPageItem, :dependent => :destroy
  has_many :secondary_linked_items, :foreign_key => :secondary_id, :class_name => LinkedPageItem, :dependent => :destroy
  has_one :interactive_page, through: :section

  COLUMN_PRIMARY ="primary"
  COLUMN_SECONDARY ="secondary"

  default_scope order('position ASC')

  def toggle_hideshow_embeddable
    embeddable.is_hidden = !embeddable.is_hidden
    embeddable.save
  end

  def duplicate(helper=nil, next_section=nil)
    helper = LaraDuplicationHelper.new if helper.nil?
    next_section = section if next_section.nil?
    emb_copy = helper.get_copy(embeddable)

    if embeddable.respond_to?(:embeddable=) && embeddable.embeddable
      emb_copy.embeddable = helper.get_copy(embeddable.embeddable)
    end
    if embeddable.respond_to?(:interactive=) && embeddable.interactive
      emb_copy.interactive = helper.get_copy(embeddable.interactive)
    end
    if embeddable.respond_to?(:linked_interactive=) && embeddable.linked_interactive
      emb_copy.linked_interactive = helper.get_copy(embeddable.linked_interactive)
    end
    emb_copy.save!(validate: false)
    if embeddable.respond_to? :question_tracker and embeddable.question_tracker
      embeddable.question_tracker.add_question(emb_copy)
    end
    next_item = next_section.page_items.create!(
      embeddable: emb_copy,
      position: position,
      column: column
    )
    next_item.move_lower
    next_item
  end
end
