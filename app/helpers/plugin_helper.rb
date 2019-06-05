module PluginHelper

  def plugin_loaded(url)
    @loaded_plugins ||= {}
    return true if @loaded_plugins[url]
    @loaded_plugins[url] = true
    false
  end

  def plugin_options(scope)
    plugins_items = ApprovedScript.authoring_menu_items(scope).map { |ami| [ami.name, ami.approved_script_id, {"data-component-label" => ami.component_label}] }
    options_for_select(plugins_items)
  end

end
