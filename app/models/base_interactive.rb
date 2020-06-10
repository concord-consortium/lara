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

  def report_service_hash
    # Expected metadata format can be checked in lara-typescript/interactive-api-client/metadata-types.ts:
    # IAuthoring<...>Metadata interfaces.
    # Metadata is simply provided as a part of authored state. It's optional and everything should work if there's
    # no metadata defined or authored state is empty.
    metadata = parsed_authored_state

    type = metadata[:questionType] || "iframe_interactive"

    result = {
      # type can be overwritten by metadata[:questionType] prop (e.g. to "open_response").
      # Otherwise, the default "iframe_interactive" will be used.
      type: type,
      # These properties are defined in IAuthoringMetadataBase:
      subtype: metadata[:subtype],
      required: metadata[:required],
      prompt: metadata[:prompt],
      # These properties are stored in LARA. They're basic interactive properties. Some of them might be unused by
      # Report or Portal when interactive pretends to be a basic question type. But these services might be extended
      # to show both basic question answer and optionally provide iframe report view.
      id: embeddable_id,
      name: name,
      url: url,
      show_in_featured_question_report: show_in_featured_question_report,
      display_in_iframe: reportable_in_iframe?,
      width: native_width,
      height: native_height,
      question_number: index_in_activity
    }

    if type === "multiple_choice"
      result.merge!({
        # This property is defined in IAuthoringMultipleChoiceMetadata:
        choices: metadata[:choices]
      })
    end

    result
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
