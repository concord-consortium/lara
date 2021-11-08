class InteractiveRunState < ActiveRecord::Base
  alias_method :original_json, :to_json  # make sure we can still generate json of the base model after including Answer
  include Embeddable::Answer # Common methods for Answer models

  attr_accessible :interactive_id, :interactive_type, :run_id, :raw_data, :interactive, :run, :key, :metadata

  belongs_to :run
  belongs_to :interactive, :polymorphic => true

  after_update :maybe_send_to_portal
  after_update :propagate_to_collaborators

  before_save :add_key_if_nil

  def self.generate_key
    SecureRandom.hex(20)
  end

  def self.by_question(q)
    where(interactive_id: q.id, interactive_type: q.class.name)
  end

  def self.by_run_and_interactive(run,interactive)
    opts = {
      interactive_id: interactive.id,
      interactive_type: interactive.class.name,
      run_id: run.id
    }
    results = self.where(opts).first
    if results.nil?
      results = self.create(opts)
    end
    return results
  end

  # When interactive "pretends" to be one of the basic types, its question type also needs to do that.
  def self.question_type_for(type)
    mapping = {
      "open_response_answer" => "open_response",
      "multiple_choice_answer" => "multiple_choice",
      "image_question_answer" => "image_question",
      "interactive_state" => "iframe_interactive",
      "external_link" => "iframe_interactive"
    }
    mapping[type] || "iframe_interactive"
  end

  def self.default_answer(conditions)
    InteractiveRunState.create({
      run: conditions[:run],
      interactive: conditions[:question]
    })
  end

  # It's important to parse metadata in a consistent way so merging works as expected.
  def self.parse_metadata(json)
    # symbolize_keys is important for consistency while merging metadata with a new metadata or report_service hash.
    if json.is_a? String
      begin
        return JSON.parse(json).symbolize_keys
      rescue JSON::ParserError
        # Ignore invalid JSONs (or empty string / nil / etc.)
        return {}
      end
    elsif json.is_a? Hash
      return json.symbolize_keys
    else
      return {}
    end
  end

  def question
    interactive
  end

  def page
    interactive.interactive_page
  end

  def activity
    page && page.lightweight_activity
  end

  # Used by CollaborationRun to copy answer to collaborators.
  def copy_answer!(another_int_run_state)
    # CFM-based projects are the only ones that use reporting URL. Currently, CFM handles run with collaborators
    # itself. Copying interactive state and replacing reporting URLs could break it.
    return if interactive.has_report_url || another_int_run_state.reporting_url.present?

    self.update_attributes!(
      raw_data: another_int_run_state.raw_data,
      metadata: another_int_run_state.metadata
    )
  end

  def portal_hash
    result = report_service_hash

    # Portal expects different types than report service.
    type_mapping = {
      "interactive_state" => "interactive",
      "external_link" => "external_link",
      "open_response_answer" => "open_response",
      "image_question_answer" => "image_question",
      "multiple_choice_answer" => "multiple_choice",
    }
    result[:type] = type_mapping[result[:type]]
    result[:is_final] = !!result[:submitted]

    if result[:type] === "external_link"
      # Not very consistent naming (missing underscore), but that's what Portal expects.
      # Note that question type is only necessary for external_link answer type.
      result[:question_type] = "iframe interactive"
    elsif result[:type] === "multiple_choice"
      result[:answer_ids] = result[:answer][:choice_ids]
      # multiple_choice_answer.rb also sends answer_texts.
      # This property is skipped here, as Portal doesn't use it anyway.
    elsif result[:type] === "image_question"
      result[:image_url] = result[:answer][:image_url]
      result[:answer] = result[:answer][:text]
    end

    if (result[:type] === "interactive" || result[:type] === "external_link") && interactive.instance_of?(MwInteractive)
      # When interactive doesn't pretend to be a basic question type, use regular ID number (instead of embeddable_id
      # used by default) to be backward compatible with existing MwInteractives that are already exported to Portal.
      # `embeddable_id` is safer when type is overwritten by interative metadata, but in this case it's not
      # necessary and lets us not break existing interactives. Note that `ManagedInteractive` states should use
      # default question_id based on embeddable_id.
      result[:question_id] = interactive.id.to_s
    end

    # Portal expects less fields that will be actually sent, but it doesn't seem to cause any problems.
    result
  end

  def parsed_interactive_state
    JSON.parse(raw_data).symbolize_keys rescue {}
  end

  def report_service_hash
    # Expected data format can be checked in lara-typescript/interactive-api-client/metadata-types.ts:
    # IRuntime<...>Metadata interfaces.
    # Metadata is simply provided as a part of interactive state. It's optional and everything should work if there's
    # no metadata defined or interactive state is empty.
    intStateMetadata = parsed_interactive_state

    # This property is defined in IRuntimeMetadataBase:
    type = intStateMetadata[:answerType] || (interactive.has_report_url ? "external_link" : "interactive_state")

    result = {}

    # Custom metadata provided by the host environment (LARA JS env). Different from the interactive state metadata
    # This metadata is used to store attachment data and `shared_with` property (used by Report Service).
    # Note that the custom metadata should extend record at the very beginning. This will ensure that it cannot
    # overwrite one of the properties defined below.
    result.merge!(InteractiveRunState::parse_metadata(self.metadata))

    result.merge!({
      # type can be overwritten by intStateMetadata[:answerType] prop (e.g. to "open_response_answer").
      # Otherwise, the default "interactive_state" or "external_link" will be used.
      type: type,
      # question_type should match answer type.
      question_type: InteractiveRunState.question_type_for(type),
      # These properties are defined in IRuntimeMetadataBase:
      submitted: intStateMetadata[:submitted],
      answer_text: intStateMetadata[:answerText],
      # These properties are stored in LARA. They're basic interactive run state properties. Some of them might be
      # unused by Report or Portal when interactive pretends to be a basic question type. But these services might be
      # extended to show both basic question answer and optionally provide iframe report view.
      id: answer_id,
      question_id: interactive.embeddable_id,
      # Even when interactive pretends to be one of the basic questions, it makes sense to add full report state
      # (combination of authored and interactive state), so the full reporting view can be displayed if necessary.
      report_state: report_state.to_json
    })

    case type
    when "multiple_choice_answer"
      # Convert selectedChoiceIds to answer:choice_ids to let interactives use more friendly naming,
      # but still be compatible with Report and Portal format.
      # selectedChoiceIds is defined in IRuntimeMultipleChoiceMetadata.
      result[:answer] = {
        choice_ids: intStateMetadata[:selectedChoiceIds]
      }
    when "open_response_answer"
      # answerText is defined in IRuntimeMetadataBase.
      # Use answer key to be compatible with current Report and Portal format.
      result[:answer] = intStateMetadata[:answerText]
    when "image_question_answer"
      # answerImageUrl is defined in IRuntimeImageQuestionMetadata.
      # # Use answer key to be compatible with current Report service format.
      result[:answer] = {
        image_url: intStateMetadata[:answerImageUrl],
        text: intStateMetadata[:answerText]
      }
    when "external_link"
      result[:answer] = reporting_url
    when "interactive_state"
      # Current Report and Portal versions expect interactive report state to be passed in "answer" property.
      # Don't remove report_state, so it's possible to update these apps to use report_state one day.
      result[:answer] = result[:report_state]
    end

    result
  end

  def maybe_send_to_portal
    if interactive.has_report_url
      send_to_portal if reporting_url.present?
    else
      send_to_portal if raw_data || metadata
    end
  end

  def reporting_url
    data = JSON.parse(raw_data) rescue {}
    (opts = data["lara_options"]) && opts["reporting_url"]
  end

  def report_state
    # Follow LARA Interactive API format. This state will be passed directly to the interactive later by the teacher
    # report app using iframe-phone `initInteractive` call. More properties can be provided here,
    # e.g. globalInteractiveState, linkedState and pretty much anything that is supported by `initInteractive`.
    # Please see LARA Interactive API docs or iframe-saver.coffee.
    # Note that Portal and Teacher Report app simply pass this state to the interactive, they don't know anything
    # about LARA Interactive API.
    {
      version: 1,
      mode: 'report',
      authoredState: interactive.authored_state,
      interactiveState: raw_data
    }
  end

  def has_linked_interactive
    (interactive.respond_to? :linked_interactive) && !interactive.linked_interactive.nil?
  end

  # Returns all linked states. 1st element in the array is an interactive directly linked to given one.
  def all_linked_states(protocol = nil, host = nil)
    result = []
    current_interactive = interactive
    while (current_interactive.respond_to? :linked_interactive) && !current_interactive.linked_interactive.nil?
      linked_interactive = current_interactive.linked_interactive
      runs = run.sequence_run ? run.sequence_run.runs : [run]
      state = InteractiveRunState.where(run_id: runs.map(&:id), interactive_id: linked_interactive.id).first
      # It's not necessary to provide some metadata even for empty linked states, although it doesn't cost much
      # and it can be useful for interactive itself to know that there are some linked interactives,
      # but not run by student yet.
      linked_state_info = if state
                            state.to_runtime_hash(protocol, host, false)
                          else
                            { interactive_id: linked_interactive.id, raw_data: nil, created_at: nil, updated_at: nil }
                          end
      result.push(linked_state_info)
      # Go to the next interactive in linked interactives chain.
      current_interactive = linked_interactive
    end
    result
  end

  def linked_state
    # Note that this method will return the first available state of the linked interactives *chain*.
    # Sometimes the interactive that is directly linked might have not be run by student yet (e.g. when he skipped a page).
    non_empty_state = all_linked_states.find { |state| state[:raw_data] }
    unless non_empty_state.nil?
      return non_empty_state[:raw_data]
    end
    # Return nil if there's no linked state.
    nil
  end

  def run_remote_endpoint
    run.remote_endpoint
  end

  # This alias makes #answer_json point at Embeddable::Answer#to_json (from inclusion of Embeddable::Answer at top)
  # ActiveRecord's #to_json had previously be aliased to #original_json. If we are called without arg, we send answer
  # json. Active Record Seiralization args are in the form of {methods: [method_names]} or {only: [field_names]} …
  alias_method :answer_json, :to_json
  def to_json(arg=nil)
    arg ? original_json(arg) : answer_json
  end

  def to_runtime_hash(protocol, host, include_linked_states = true)
    hash = {
        id: id,
        key: key,
        raw_data: raw_data,
        metadata: metadata,
        learner_url: learner_url,
        run_remote_endpoint: run_remote_endpoint,
        interactive_state_url: interactive_state_url(protocol, host),
        interactive_id: interactive_id,
        interactive_name: interactive.name,
        interactive_question_id: interactive.embeddable_id,
        page_number: page && page.page_number,
        page_name: page && page.name,
        activity_name: activity && activity.name,
        created_at: created_at,
        updated_at: updated_at,
        # User activity run (not to confuse with InteractiveStateRun which could be called just InteractiveState)
        external_report_url: ReportService::report_url(run, interactive.activity, nil, interactive)
    }
    if include_linked_states
      hash[:has_linked_interactive] = has_linked_interactive
      hash[:linked_state] = linked_state
      hash[:all_linked_states] = all_linked_states(protocol, host)
    end
    hash
  end

  def to_runtime_json(protocol, host, include_linked_states = true)
    to_runtime_hash(protocol, host, include_linked_states).to_json
  end

  def answered?
    # if interactives have a reporting url they are answered only if that reporting url
    # is available. Otherwise any run state counts as answered.
    # Also note that even though interactive_run_states are considered polymorphic
    # they are actually only used by MwInteractive
    if interactive.has_report_url
      reporting_url.present?
    else
      raw_data.present?
    end
  end

  def add_key_if_nil
    self.key = InteractiveRunState.generate_key if self.key.nil?
  end

  def interactive_state_url(protocol, host)
    if protocol && host
      Rails.application.routes.url_helpers.api_v1_show_interactive_run_state_url(key: self.key, protocol: protocol, host: host)
    else
      nil
    end
  end
end
