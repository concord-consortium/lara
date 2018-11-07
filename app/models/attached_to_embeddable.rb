module AttachedToEmbeddable
  def self.included(clazz)
    clazz.class_eval do
      # That requires model that includes this module to have embeddable_id (integer) and embeddable_type (string) attributes.
      belongs_to :embeddable, :polymorphic => true

      attr_accessible :embeddable_select_value
      attr_writer :embeddable_select_value

      before_validation :parse_embeddable_select_value
    end
  end

  NO_EMBEDDABLE_LABEL = I18n.t('NO_EMBEDDABLE')
  NO_EMBEDDABLE_VALUE = "no-embeddable"
  NO_EMBEDDABLE_SELECT = [NO_EMBEDDABLE_LABEL, NO_EMBEDDABLE_VALUE]

  def possible_embeddables
    page ? page.embeddables : []
  end

  def embeddables_for_select
    # Because embeddable is polymorphic association, normal AR options for select don't work.
    options = [NO_EMBEDDABLE_SELECT]
    possible_embeddables.each_with_index do |pi, i|
      # Do not let embeddable attach to itself
      next if pi === self
      hidden_text =  pi.is_hidden? ? "(hidden)" : ""
      options << ["#{pi.class.model_name.human} #{hidden_text}(#{i+1})", make_embeddable_select_value(pi)]
    end
    options
  end

  def embeddable_select_value
    return @embeddable_select_value if @embeddable_select_value
    return make_embeddable_select_value(embeddable) if embeddable
  end

  def make_embeddable_select_value(embeddable)
    "#{embeddable.id}-#{embeddable.class.name}"
  end

  def parse_embeddable_select_value
    # Parse the embeddable form select input value
    # Turn it into a type of embeddable, or nil.
    if embeddable_select_value
      _embeddable = nil
      if embeddable_select_value != NO_EMBEDDABLE_VALUE
        id, model = self.embeddable_select_value.split('-')
        _embeddable = Kernel.const_get(model).send(:find, id) rescue nil
      end
      self.embeddable = _embeddable
    end
  end
end
