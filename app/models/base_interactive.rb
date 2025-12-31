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

  # used for react-based authoring
  def to_authoring_hash
    hash = to_hash
    hash[:id] = id
    hash[:linked_interactive_id] = linked_interactive_id
    hash[:linked_interactive_type] = linked_interactive_type
    hash[:aspect_ratio] = aspect_ratio
    hash[:interactive_item_id] = interactive_item_id
    hash[:linked_interactive_item_id] = linked_interactive_item_id
    hash[:data_source_interactive_item_id] = data_source_interactive_item_id
    # Note that linked_interactives is independent from linked_interactive_id and linked_interactive_type fields
    hash[:linked_interactives] = linked_interactives_list
    hash
  end

  def authoring_api_urls(protocol, host)
    {
      get_interactive_list: interactive_page ? Rails.application.routes.url_helpers.api_v1_get_interactive_list_url(id: interactive_page.id, protocol: protocol, host: host) : nil,
    }
  end

  def portal_hash
    result = report_service_hash
    # When Portal receives iframe_interactive, it expects:
    # id, name, url, native_width, native_height, is_required, display_in_iframe.
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
      result[:name] = BaseInteractive.clean_value(result[:prompt]).truncate(200)
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
      display_in_iframe: reportable_in_iframe?,
      width: native_width,
      height: native_height,
      question_number: index_in_activity,
      authored_state: parsed_authored_state,
      report_item_url: report_item_url
    }

    if type === "multiple_choice"
      result.merge!({
        # This property is defined in IAuthoringMultipleChoiceMetadata:
        choices: (metadata[:choices] || []).map { |c| (c || {}).symbolize_keys.slice(:id, :content, :correct) }
      })
    elsif type === "image_question"
      result.merge!({
        # This property is defined in IAuthoringImageQuestionMetadata.
        # It can be confusing that drawing prompt == answer prompt. The property has been renamed while image question
        # interactive was developed. It seems to make sense, as this prompt is rendered next to textarea.
        drawing_prompt: metadata[:answerPrompt]
      })
    end

    result
  end

  def page_section
    page_item&.section&.title || false
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

  def make_interactive_item_id(interactive)
    interactive.page_item ? "interactive_#{interactive.page_item.id}" : nil
  end

  def interactive_item_id
    make_interactive_item_id(self)
  end

  def linked_interactive_item_id
    linked_interactive ? make_interactive_item_id(linked_interactive) : nil
  end

  def linked_interactive_item_id=(val)
    matches = val.nil? ? nil : val.match(/^interactive_(.+)$/)
    page_item = matches ? PageItem.find_by_id(matches[1]) : nil
    if page_item
      self.linked_interactive = page_item.embeddable
    else
      # A way to unlink interactive
      self.linked_interactive = nil
    end
  end

  # legacy ref_id format (might be useful in some cases)
  def data_source_interactive_ref_id
    data_source_interactive ? "#{data_source_interactive.id}-#{data_source_interactive.class.to_s}" : nil
  end

  # used at runtime to get the data source interactive id in format used in Firebase
  def data_source_interactive_embeddable_id
    data_source_interactive ? "#{Embeddable.get_embeddable_class(data_source_interactive.class)}_#{data_source_interactive.id}" : nil
  end

  # used at authoring time
  def data_source_interactive_item_id
    data_source_interactive ? make_interactive_item_id(data_source_interactive) : nil
  end

  # used at authoring time
  def data_source_interactive_item_id=(val)
    matches = val.nil? ? nil : val.match(/^interactive_(.+)$/)
    page_item = matches ? PageItem.find_by_id(matches[1]) : nil
    if page_item
      self.data_source_interactive = page_item.embeddable
    else
      # A way to unlink interactive
      self.data_source_interactive = nil
    end
  end

  def self.clean_value(value)
    value.class == String ? clean_text(value) : value
  end

  def self.clean_text(text)
    Nokogiri::HTML(text).inner_text
  end

end
