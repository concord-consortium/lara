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
    result = report_service_hash
    # When Portal receives iframe_interactive, it expects:
    # id, name, url, native_width, native_height, is_required, show_in_featured_question_report, display_in_iframe.
    # Add / map property names that are different in report_service_hash.

    result[:native_width] = result[:width]
    result[:native_height] = result[:height]
    result[:is_required] = !!result[:required]
    if result[:prompt].nil?
      # Portal doesn't like nil prompt. Publication fails with:
      # HTTP Unprocessable Entity 422
      # NoMethodError: undefined method `gsub' for nil:NilClass
      # Details: https://www.pivotaltracker.com/story/show/173400823
      result[:prompt] = ""
    end

    # If name is not available, but prompt is, this should make Portal details report a bit more readable.
    unless result[:name].present?
      result[:name] = result[:prompt]
    end

    # Open response and multiple choice properties are the same as in report_service_hash and/or properties mapped above.
    # Portal expects less fields that will be actually sent, but it doesn't seem to cause any problems.
    result
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
      sub_type: metadata[:questionSubType],
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
      question_number: index_in_activity,
      authored_state: parsed_authored_state
    }

    if type === "multiple_choice"
      result.merge!({
        # This property is defined in IAuthoringMultipleChoiceMetadata:
        choices: (metadata[:choices] || []).map { |c| (c || {}).symbolize_keys.slice(:id, :content, :correct) }
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

  def linked_interactives_list
    list = []
    if page_item
      LinkedPageItem.where(primary_id: page_item.id).each do |linked_page_item|
        list.push({id: "interactive_#{linked_page_item.secondary_id}", label: linked_page_item.label})
      end
    end
    list
  end

end
