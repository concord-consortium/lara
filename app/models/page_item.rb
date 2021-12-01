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

  def set_linked_interactives(options)
    source_page_item_id = id

    ActiveRecord::Base.transaction do
      if options.has_key?("linkedInteractives")
        linked_interactives = options["linkedInteractives"]
        # clear the existing links
        LinkedPageItem.delete_all(primary_id: source_page_item_id)

        # convert {0: {id:...}, 1: {id: ...}} to [{id:...}, {id:...}]
        if linked_interactives.is_a? Hash
          linked_interactives = linked_interactives.values
        end

        # add the new links
        linked_interactives.each do |item|
          if !item.is_a? Hash
            raise "Invalid linkedInteractives parameter, each array item needs to be a hash"
          end
          if item["id"].nil? || item["label"].nil?
            raise "Missing id or label value in linkedInteractives item"
          end
          secondary_id = extract_page_item_id(item["id"])
          if secondary_id.nil?
            raise "Invalid interactive id: #{item["id"]}"
          end
          item = LinkedPageItem.new({primary_id: source_page_item_id, secondary_id: secondary_id, label: item["label"]})
          if !item.save
            raise "Unable to create linkedInteractive for #{item["id"]}"
          end
        end
      end

      if options.has_key?("linkedState")
        linked_state_page_item_id = options["linkedState"].nil? ? nil : extract_page_item_id(options["linkedState"])
        if linked_state_page_item_id
          linked_state_page_item = section.page_items.find { |i| i.id == linked_state_page_item_id.to_i }
          if !linked_state_page_item
            raise "Invalid linkedState parameter in request"
          end
          embeddable.linked_interactive = linked_state_page_item.embeddable
          if !embeddable.save
            raise "Unable to set linkedState to #{linked_state_page_item_id}"
          end
        else
          embeddable.linked_interactive = nil
          if !embeddable.save
            raise "Unable to remove linkedState"
          end
        end
      end
    end
  end

  def extract_page_item_id(interactive_id)
    m = interactive_id.match(/^interactive_(.+)$/)
    m ? m[1] : nil
  end

  def export(export_helper)
    export_hash = export_helper.export(embeddable)
    export_hash[:column] = column
    export_hash[:position] = position
    export_hash
  end
end
