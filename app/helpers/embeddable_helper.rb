module EmbeddableHelper

  def embeddable_selector
    select_tag :embeddable_type, options_for_select(Embeddable::Types.map { |k,v| [v, k.to_s] })
  end

  def embeddable_interactives_selector
    select_tag :embeddable_type, options_for_select(Embeddable::InteractiveTypes.map { |k,v| [v, k.to_s] })
  end

end
