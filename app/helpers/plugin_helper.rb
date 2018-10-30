module PluginHelper

  def plugin_loaded(url)
    @loaded_plugins ||= {}
    if @loaded_plugins[url]
      true
    else
      @loaded_plugins[url] = true
      false
    end
  end

end
