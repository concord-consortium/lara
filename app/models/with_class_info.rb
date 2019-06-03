module WithClassInfo

  # If we have new class_info_url or class_hash in our query params
  # set our class_hash and class_info URLs to that (if they are blank)
  # Discussion: Not setting these values if they are already set seems safest.
  # Returns changed attributes, or false if nothing was changed.
  def update_class_info(raw_params)
    params = raw_params.stringify_keys
    new_class_info_url = params['class_info_url']
    new_class_hash = params['class_hash']
    update_attributes = {}
    changed = false
    if new_class_info_url && (self.class_info_url.blank?)
      update_attributes[:class_info_url] = new_class_info_url
      changed = true
    end
    if new_class_hash && (self.class_hash.blank?)
      update_attributes[:class_hash] = new_class_hash
      changed = true
    end
    if (changed)
      self.update_attributes(update_attributes)
      return update_attributes
    end
    return false
  end

end
