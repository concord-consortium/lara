module WithPlatformInfo
  # If we have new platform info in our query params, update db attributes.
  # Discussion: Not setting these values if they are already set seems safest.
  # Returns changed attributes, or false if nothing was changed.
  def update_platform_info(raw_params)
    params = raw_params.stringify_keys
    new_class_info_url = params['class_info_url']
    new_context_id = params['context_id']
    new_platform_id = params['platform_id']
    new_platform_user_id = params['platform_user_id']
    new_resource_link_id = params['resource_link_id']
    if new_class_info_url && self.class_info_url.blank?
      update({ class_info_url: new_class_info_url })
    end
    if new_context_id && self.context_id.blank?
      update({ context_id: new_context_id })
    end
    if new_platform_id && self.platform_id.blank?
      update({ platform_id: new_platform_id })
    end
    if new_platform_user_id && self.platform_user_id.blank?
      update({ platform_user_id: new_platform_user_id })
    end
    if new_resource_link_id && self.resource_link_id.blank?
      update({ resource_link_id: new_resource_link_id })
    end
  end
end
