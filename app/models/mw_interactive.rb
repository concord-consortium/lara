class MwInteractive < ActiveRecord::Base
  include Embeddable

  DEFAULT_CLICK_TO_PLAY_PROMPT = "Click here to start the interactive."
  ASPECT_RATIO_DEFAULT_WIDTH   = 576
  ASPECT_RATIO_DEFAULT_HEIGHT  =  435
  ASPECT_RATIO_DEFAULT_METHOD  = 'DEFAULT'
  ASPECT_RATIO_MANUAL_METHOD   = 'MANUAL'
  ASPECT_RATIO_MAX_METHOD      = 'MAX'

  attr_accessible :name, :url, :native_width, :native_height,
    :enable_learner_state, :has_report_url, :click_to_play,
    :click_to_play_prompt, :image_url, :is_hidden, :linked_interactive_id,
    :full_window, :model_library_url, :authored_state, :no_snapshots,
    :show_delete_data_button, :show_in_featured_question_report, :is_full_width,
    :aspect_ratio_method

  default_value_for :native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates_numericality_of :native_width
  validates_numericality_of :native_height

  has_one :page_item, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :page_item
  has_many :interactive_run_states, :as => :interactive, :dependent => :destroy

  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'
  belongs_to :linked_interactive, :class_name => 'MwInteractive'

  after_update :update_labbook_options

  def self.string_name
    "iframe interactive"
  end

  def self.portal_type
    "iframe interactive"
  end

  def available_aspect_ratios
    [
      MwInteractive::ASPECT_RATIO_DEFAULT_METHOD,
      MwInteractive::ASPECT_RATIO_MANUAL_METHOD,
      MwInteractive::ASPECT_RATIO_MAX_METHOD
    ].map do |key|
      { key: key, value: I18n.t("INTERACTIVE.ASPECT_RATIO.#{key}") }
    end
  end
  # returns the aspect ratio of the interactive, dividing the width by the height.
  # For an interactive with a native width of 400 and native height of 200,
  # the aspect_ratio will be 2.
  # If ASPECT_RATIO_MAX_METHOD is being used, it is expected that the available
  # width and height are provided as arugments used to calculated an aspect_ratio
  def aspect_ratio(avail_width=nil, avail_height=nil)
    case self.aspect_ratio_method
      when ASPECT_RATIO_DEFAULT_METHOD
        return ASPECT_RATIO_DEFAULT_WIDTH / ASPECT_RATIO_DEFAULT_HEIGHT.to_f
      when ASPECT_RATIO_MANUAL_METHOD
        return self.native_width/self.native_height.to_f
      when ASPECT_RATIO_MAX_METHOD
        width  = avail_width  || ASPECT_RATIO_DEFAULT_WIDTH
        height = avail_height || ASPECT_RATIO_DEFAULT_HEIGHT
        return width / height.to_f
    end
  end

  def height(avail_width, avail_height=nil)
    return avail_width / aspect_ratio(avail_width, avail_height)
  end

  def to_hash
    # Deliberately ignoring user (will be set in duplicate)
    {
      name: name,
      url: url,
      native_width: native_width,
      native_height: native_height,
      enable_learner_state: enable_learner_state,
      show_delete_data_button: show_delete_data_button,
      has_report_url: has_report_url,
      click_to_play: click_to_play,
      click_to_play_prompt: click_to_play_prompt,
      full_window: full_window,
      image_url: image_url,
      is_hidden: is_hidden,
      is_full_width: is_full_width,
      show_in_featured_question_report: show_in_featured_question_report,
      model_library_url: model_library_url,
      authored_state: authored_state,
      aspect_ratio_method: aspect_ratio_method
    }
  end

  def portal_hash
    iframe_data = to_hash
    iframe_data[:type] = 'iframe_interactive'
    iframe_data[:id] = id
    iframe_data[:display_in_iframe] = reportable_in_iframe?
    iframe_data
  end

  def duplicate
    # Generate a new object with those values
    MwInteractive.new(self.to_hash)
    # N.B. the duplicate hasn't been saved yet
  end

  def storage_key
    if name.present?
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}_#{name.downcase.gsub(/ /, '_')}"
    else
      "#{interactive_page.lightweight_activity.id}_#{interactive_page.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}"
    end
  end

  def export
    return self.as_json(only:[:name,
                              :url,
                              :native_width,
                              :native_height,
                              :enable_learner_state,
                              :show_delete_data_button,
                              :has_report_url,
                              :click_to_play,
                              :click_to_play_prompt,
                              :full_window,
                              :show_in_featured_question_report,
                              :image_url,
                              :is_hidden,
                              :is_full_width,
                              :model_library_url,
                              :authored_state,
                              :aspect_ratio_method])
  end

  def self.import(import_hash)
    return self.new(import_hash)
  end

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
    # An MwInactive should only be reported on in iframe if it doesn't have a report url
    # This is mainly for backwards compatibility. Previously interactives were only
    # reportable if they had a report_url, and they always showed as links (not iframes)
    # in the report. We want these old interactives to continue to work that way.
    # If we need more flexibility then we'll need to add a new option on MwInteractive
    # indicated if the interactive should be reported on in an iframe or not
    !has_report_url
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
