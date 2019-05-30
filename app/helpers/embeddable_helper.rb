module EmbeddableHelper

  def embeddable_selector
    embeddable_types = Embeddable::Types.map { |k,v| [v, k.to_s] }
    plugins_items = ApprovedScript.authoring_menu_items("embeddable").map { |ami| [ami.component_name, Embeddable::EmbeddablePlugin.to_s, {"data-approved-script-id" => ami.approved_script_id, "data-component-label" => ami.component_label}] }
    select_tag :embeddable_type, options_for_select(embeddable_types + plugins_items)
  end

  def embeddable_interactives_selector
    select_tag :embeddable_type, options_for_select(Embeddable::InteractiveTypes.map { |k,v| [v, k.to_s] })
  end

end
