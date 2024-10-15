class MwInteractive < ActiveRecord::Base
  include BaseInteractive
  include Embeddable
  include HasAspectRatio

  attr_accessible :name, :url, :native_width, :native_height,
    :enable_learner_state, :has_report_url, :click_to_play,
    :click_to_play_prompt, :image_url, :is_hidden, :linked_interactive_id, :linked_interactive_type,
    :full_window, :model_library_url, :authored_state, :no_snapshots,
    :show_delete_data_button, :show_in_featured_question_report, :is_half_width,
    :aspect_ratio_method, :linked_interactive_item_id, :report_item_url

  default_value_for :native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates_numericality_of :native_width
  validates_numericality_of :native_height

  has_one :page_item, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too

  has_many :primary_linked_items, :through => :page_item
  has_many :secondary_linked_items, :through => :page_item

  has_one :interactive_page, :through => :page_item
  has_many :interactive_run_states, :as => :interactive, :dependent => :destroy

  has_many :embeddable_plugins, class_name: "Embeddable::EmbeddablePlugin", as: :embeddable
  has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref

  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'
  belongs_to :linked_interactive, :polymorphic => true

  after_update :update_labbook_options

  def self.portal_type
    "iframe interactive"
  end

  def portal_hash
    result = super # BaseInteractive#portal_hash
    if result[:type] === "iframe_interactive"
      # When interactive doesn't pretend to be a basic question type, use regular ID number (instead of embeddable_id
      # used by default) to be backward compatible with existing MwInteractives that are already exported to Portal.
      # `embeddable_id` is safer when type is overwritten by interative metadata, but in this case it's not necessary
      # and lets us not break existing interactives.
      result[:id] = id
    end
    result
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
      is_half_width: is_half_width,
      show_in_featured_question_report: show_in_featured_question_report,
      model_library_url: model_library_url,
      authored_state: authored_state,
      aspect_ratio_method: aspect_ratio_method,
      no_snapshots: no_snapshots,
      linked_interactive_item_id: linked_interactive_item_id,
      linked_interactives: linked_interactives_list,
      report_item_url: report_item_url
    }
  end

  def to_authoring_preview_hash
    to_authoring_hash
  end

  def duplicate
    # Remove linked_interactives from the hash since it can't be mapped to a database column like the other 
    # properties in the hash can, and so causes an error when we try to create the duplicate interactive.
    new_interactive_hash = self.to_hash.except!(:linked_interactives)
    # Generate a new object with those values
    MwInteractive.new(new_interactive_hash)
    # N.B. the duplicate hasn't been saved yet
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
                              :is_half_width,
                              :model_library_url,
                              :authored_state,
                              :aspect_ratio_method,
                              :no_snapshots,
                              :report_item_url])
  end

  def self.import(import_hash)
    return self.new(import_hash)
  end

  def reportable?
    enable_learner_state && !hide_question_number
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

  # This approach is temporary, it is specific for ITSI style authoring.
  # It allows authors to select a special interactive, and then the labbook automatically becomes an
  # uploading labbook
  # If we keep the data modeling for this, then this code should be moved to the ITSI style authoring
  # javascript code.
  # Better yet would be to find another way to model and/or author this.
  #
  # NOTE: this is not supported in the new ManagedInteractives
  #
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

  def prompt
    name
  end

  def thumbnail_url
    # mirror managed_interactive has thumbnail_url which proxies to library_interactive
    image_url
  end
end
