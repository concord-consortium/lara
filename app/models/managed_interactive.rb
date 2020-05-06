class ManagedInteractive < ActiveRecord::Base
  include Embeddable
  include HasAspectRatio

  DEFAULT_CLICK_TO_PLAY_PROMPT = "Click here to start the interactive."

  attr_accessible :library_interactive_id,
    :name,
    :url_fragment,
    :is_full_width,
    :show_in_featured_question_report,
    :authored_state,
    :is_hidden,
    :linked_interactive_id,
    :inherit_aspect_ratio_method, :custom_aspect_ratio_method,
    :inherit_native_width, :custom_native_width,
    :inherit_native_height, :custom_native_height,
    :inherit_click_to_play, :custom_click_to_play,
    :inherit_full_window, :custom_full_window,
    :inherit_click_to_play_prompt, :custom_click_to_play_prompt,
    :inherit_image_url, :custom_image_url

  default_value_for :custom_native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :custom_native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates :name, presence: true
  validates :url_fragment, presence: true

  validates_numericality_of :custom_native_width
  validates_numericality_of :custom_native_height

  belongs_to :library_interactive

  has_one :page_item, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :page_item
  has_many :interactive_run_states, :as => :interactive, :dependent => :destroy

  # REVIEW TODO: is update_labbook_options needed?
  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'

  belongs_to :linked_interactive, :class_name => 'ManagedInteractive'

  # REVIEW TODO: is update_labbook_options needed?
  after_update :update_labbook_options

  def self.table_name
    'managed_interactives'
  end

  # getter for constructed url
  def url
    # BONUS: parse library_interactive.base_url query parameters and merge them with url_fragment query parameters
    "#{library_interactive.base_url}#{url_fragment}"
  end

  # getters for inherited attributes
  def aspect_ratio_method
    inherit_aspect_ratio_method ? library_interactive.aspect_ratio_method : custom_aspect_ratio_method
  end

  def native_width
    inherit_native_width ? library_interactive.native_width : custom_native_width
  end

  def native_height
    inherit_native_height ? library_interactive.native_height : custom_native_height
  end

  def click_to_play
    inherit_click_to_play ? library_interactive.click_to_play : custom_click_to_play
  end

  def full_window
    inherit_full_window ? library_interactive.full_window : custom_full_window
  end

  def click_to_play_prompt
    inherit_click_to_play_prompt ? library_interactive.click_to_play_prompt : custom_click_to_play_prompt
  end

  def image_url
    inherit_image_url ? library_interactive.image_url : custom_image_url
  end

  def enable_learner_state
    library_interactive ? library_interactive.enable_learner_state : false
  end

  def show_delete_data_button
    library_interactive ? library_interactive.show_delete_data_button : false
  end

  def self.string_name
    "managed interactive"
  end

  def self.portal_type
    "iframe interactive"
  end

  def storage_key
    if name.present?
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}_#{name.downcase.gsub(/ /, '_')}"
    else
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}"
    end
  end

  def to_hash
    # Deliberately ignoring user (will be set in duplicate)
    {
      library_interactive_id: library_interactive_id,
      name: name,
      url_fragment: url_fragment,
      authored_state: authored_state,
      is_hidden: is_hidden,
      is_full_width: is_full_width,
      show_in_featured_question_report: show_in_featured_question_report,
      inherit_aspect_ratio_method: inherit_aspect_ratio_method,
      custom_aspect_ratio_method: custom_aspect_ratio_method,
      inherit_native_width: inherit_native_width,
      custom_native_width: custom_native_width,
      inherit_native_height: inherit_native_height,
      custom_native_height: custom_native_height,
      inherit_click_to_play: inherit_click_to_play,
      custom_click_to_play: custom_click_to_play,
      inherit_full_window: inherit_full_window,
      custom_full_window: custom_full_window,
      inherit_click_to_play_prompt: inherit_click_to_play_prompt,
      custom_click_to_play_prompt: custom_click_to_play_prompt,
      inherit_image_url: inherit_image_url,
      custom_image_url: custom_image_url
    }
  end

  def portal_hash
    iframe_data = to_hash
    iframe_data[:type] = 'iframe_interactive'
    iframe_data[:id] = id
    iframe_data[:display_in_iframe] = reportable_in_iframe?
    iframe_data
  end

  def report_service_hash
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

  def duplicate
    # Generate a new object with those values
    ManagedInteractive.new(self.to_hash)
    # N.B. the duplicate hasn't been saved yet
  end

  def export
    hash = to_hash()
    hash.delete(:library_interactive_id)
    hash[:library_interactive] = {
      hash: library_interactive.generate_export_hash(),
      data: library_interactive.to_hash()
    }
    hash.to_json()
  end

  def self.import(import_hash)
    # save off the imported library interactive to hydrate it after the instance is created
    parsed = JSON.parse(import_hash)
    imported_library_interactive = parsed["library_interactive"]
    parsed.delete("library_interactive")

    managed_interactive = self.new(parsed)

    # find the existing matching library interactive or create a new one
    if imported_library_interactive
      library_interactive = LibraryInteractive.find_by_export_hash(imported_library_interactive["hash"])
      if library_interactive
        managed_interactive.library_interactive = library_interactive
      else
        managed_interactive.library_interactive = LibraryInteractive.import(imported_library_interactive["data"])

        # REVIEW QUESTION: should we call #save here - if we don't and the user imports an activity
        # that uses the same library interactive more than once it won't find the newly created
        # library interactive
      end
    end

    managed_interactive
  end

  # REVIEW TODO: is update_labbook_options needed?

  # This approach is temporary, it is specific for ITSI style authoring.
  # It allows authors to select a special interactive, and then the labbook automatically becomes an
  # uploading labbook
  # If we keep the data modeling for this, then this code should be moved to the ITSI style authoring
  # javascript code.
  # Better yet would be to find another way to model and/or author this.
  def update_labbook_options
    if labbook
      upload_only_model_urls = (ENV['UPLOAD_ONLY_MODEL_URLS'] or '').split('|').map { |url| url.squish }
      if upload_only_model_urls.include? url
        labbook.action_type = Embeddable::Labbook::UPLOAD_ACTION
        labbook.custom_action_label = "Take a Snapshot"
        labbook.prompt = I18n.t 'LABBOOK.ITSI.UPLOAD_PROMPT'
        labbook.save!
      else
        if upload_only_model_urls.include? url_was
          labbook.action_type = Embeddable::Labbook::SNAPSHOT_ACTION
          labbook.custom_action_label = nil
          labbook.prompt = I18n.t 'LABBOOK.ITSI.SNAPSHOT_PROMPT'
          labbook.save!
        end
      end
    end
  end

  def reportable?
    enable_learner_state
  end

  def reportable_in_iframe?
    true
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
