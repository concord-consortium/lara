class PageSerializationHelper
  def chache_interactive_copy(original_interactive, copy_of_interactive)
    @entries ||= {}
    @entries[key(original_interactive)] = copy_of_interactive
  end
  def lookup_new_interactive(original_interactive)
    @entries ||= {}
    @entries[key(original_interactive)]
  end
  private
  def key(interactive)
    "#{interactive.id}-#{interactive.class.name}"
  end
end
