# common constants and methods for MWInteractive and ManagedInteractive

module BaseInteractive
  DEFAULT_CLICK_TO_PLAY_PROMPT = "Click here to start the interactive."

  def storage_key
    if name.present?
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}_#{name.downcase.gsub(/ /, '_')}"
    else
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}"
    end
  end

  def portal_hash
    iframe_data = to_hash
    iframe_data[:type] = 'iframe_interactive'
    iframe_data[:id] = id
    iframe_data[:display_in_iframe] = reportable_in_iframe?
    iframe_data
  end

  def parsed_authored_state
    JSON.parse(authored_state).symbolize_keys rescue {}
  end

  def basic_question_type_hash
    # Expected data format can be checked in lara-typescript/interactive-api-client/types.ts:
    # IAuthoringMetadata<...> interfaces.
    data = parsed_authored_state

    if data[:type] === "open_response" || data[:type] === "multiple_choice"
      basic_props = {
        id: embeddable_id,
        show_in_featured_question_report: show_in_featured_question_report,
        question_number: index_in_activity,
      }
      return basic_props.merge(data)
    end
    nil
  end

  def report_service_hash
    return basic_question_type_hash if basic_question_type_hash

    {
      type: 'iframe_interactive',
      id: embeddable_id,
      name: name,
      url: url,
      show_in_featured_question_report: show_in_featured_question_report,
      display_in_iframe: reportable_in_iframe?,
      width: native_width,
      height: native_height,
      question_number: index_in_activity
    }
  end

  def page_section
    page_item && page_item.section
  end

  def question_index
    if respond_to? :index_in_activity
      begin
        return self.index_in_activity()
      rescue StandardError => e
        logger.warn "Rescued #{e.class}: #{e.message}"
      end
    end
    return nil
  end

end
