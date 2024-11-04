module AttachedToInteractive
  def self.included(clazz)
    clazz.class_eval do
      # That requires model that includes this module to have interactive_id (integer) and interactive_type (string) attributes.
      belongs_to :interactive, polymorphic: true

      # attr_accessible :interactive_select_value
      attr_writer :interactive_select_value

      before_validation :parse_interactive_select_value
    end
  end

  NO_INTERACTIVE_LABEL =   I18n.t('NO_INTERACTIVE')
  NO_INTERACTIVE_VALUE = "no-interactive"
  NO_INTERACTIVE_SELECT = [NO_INTERACTIVE_LABEL, NO_INTERACTIVE_VALUE]

  def possible_interactives
    page ? page.interactives : []
  end

  def interactives_for_select
    # Because interactive is polymorphic association, normal AR options for select don't work.
    options = [NO_INTERACTIVE_SELECT]
    possible_interactives.each_with_index do |pi, i|
      hidden_text =  pi.is_hidden? ? "(hidden)" : ""
      options << ["#{pi.class.model_name.human} #{hidden_text}(#{i+1})", make_interactive_select_value(pi)]
    end
    options
  end

  def interactive_select_value
    return @interactive_select_value if @interactive_select_value
    return make_interactive_select_value(interactive) if interactive
  end

  def make_interactive_select_value(interactive)
    "#{interactive.id}-#{interactive.class.name}"
  end

  def parse_interactive_select_value
    # Parse the interactive form select input value
    # Turn it into a type of interactive, or nil.
    if interactive_select_value
      _interactive = nil
      if interactive_select_value != NO_INTERACTIVE_VALUE
        id, model = self.interactive_select_value.split('-')
        _interactive = Kernel.const_get(model).send(:find, id) rescue nil
      end
      self.interactive = _interactive
    end
  end
end
