module AttachedToEmbeddable
  def self.included(clazz)
    clazz.class_eval do
      # That requires model that includes this module to have embeddable_id (integer) and embeddable_type (string) attributes.
      belongs_to :embeddable, polymorphic: true

      # attr_accessible :embeddable_select_value
      attr_writer :embeddable_select_value

      before_validation :parse_embeddable_select_value
    end
  end

  NO_EMBEDDABLE_LABEL = I18n.t('NO_EMBEDDABLE')
  NO_EMBEDDABLE_VALUE = "no-embeddable"
  NO_EMBEDDABLE_SELECT = [NO_EMBEDDABLE_LABEL, NO_EMBEDDABLE_VALUE]

  # Model can be attached to the next embeddable present on a given page.
  # It will be calculated dynamically when needed (see embeddable method below).
  # That way, an author can use embeddable item positioning to wrap other embeddables / attach them to each other.
  NEXT_EMBEDDABLE_LABEL = I18n.t('NEXT_EMBEDDABLE')
  NEXT_EMBEDDABLE_VALUE = "next-embeddable"
  NEXT_EMBEDDABLE_SELECT = [NEXT_EMBEDDABLE_LABEL, NEXT_EMBEDDABLE_VALUE]

  def embeddable
    if attached_to_next_embeddable
      # p_item is a page item, which `acts as a list`. That lets us quickly get the next item and embeddable
      # without loading all the embeddables and manually checking index.
      next_page_item = p_item.lower_item
      next_page_item && next_page_item.embeddable
    else
      super
    end
  end

  def attached_to_next_embeddable
    embeddable_type == NEXT_EMBEDDABLE_VALUE
  end

  def attached_to_embeddable
    # Note that it's not enough to check embeddable value. If this item is the last one in the page and is attached
    # to the next interactive, #embeddable will return nil. However, we still should consider this item as attached
    # to something (e.g. in authoring forms).
    attached_to_next_embeddable || !!embeddable
  end

  def possible_embeddables
    # Do not let embeddable attach to itself
    page ? page.embeddables.select { |e| e != self } : []
  end

  def embeddables_for_select
    # Because embeddable is polymorphic association, normal AR options for select don't work.
    options = [NO_EMBEDDABLE_SELECT, NEXT_EMBEDDABLE_SELECT]
    possible_embeddables.each do |possible_embed|
      options << [make_embeddable_select_label(possible_embed), make_embeddable_select_value(possible_embed)]
    end
    options
  end

  def embeddable_select_value
    return @embeddable_select_value if @embeddable_select_value
    if attached_to_next_embeddable
      NEXT_EMBEDDABLE_VALUE
    else
      make_embeddable_select_value(embeddable) if embeddable
    end
  end

  def embeddable_select_label
    if attached_to_next_embeddable
      NEXT_EMBEDDABLE_LABEL
    else
      make_embeddable_select_label(embeddable) if embeddable
    end
  end

  def make_embeddable_select_value(embeddable)
    "#{embeddable.id}-#{embeddable.class.name}"
  end

  def make_embeddable_select_label(embeddable)
    hidden_text =  embeddable.is_hidden? ? "(hidden)" : ""
    "#{embeddable.class.model_name.human} #{hidden_text}(#{page.embeddables.index(embeddable) + 1})"
  end

  def parse_embeddable_select_value
    # Parse the embeddable form select input value
    # Turn it into a type of embeddable, or nil.
    if embeddable_select_value
      _embeddable = nil
      if embeddable_select_value == NEXT_EMBEDDABLE_VALUE
        self.embeddable_type = NEXT_EMBEDDABLE_VALUE
      elsif embeddable_select_value == NO_EMBEDDABLE_VALUE
        self.embeddable = nil
      else embeddable_select_value != NO_EMBEDDABLE_VALUE
        id, model = self.embeddable_select_value.split('-')
        _embeddable = Kernel.const_get(model).send(:find, id) rescue nil
        self.embeddable = _embeddable
      end
    end
  end
end
