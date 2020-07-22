# In the UI the ManagedInteractive model is called Library Interactive
# There is also a LibraryInteractive model which are the items in the
# interactive library
class ManagedInteractive < ActiveRecord::Base
  include BaseInteractive
  include Embeddable
  include HasAspectRatio

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

  validates_numericality_of :custom_native_width
  validates_numericality_of :custom_native_height

  belongs_to :library_interactive

  has_one :page_item, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :page_item
  has_many :interactive_run_states, :as => :interactive, :dependent => :destroy

  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'

  belongs_to :linked_interactive, :class_name => 'ManagedInteractive'

  # getter for constructed url
  def url
    # BONUS: instead of returnng nil return a placeholder url that shows a "No interative selecte yet" message
    # in both authoring and runtime
    return nil unless library_interactive
    # BONUS: parse library_interactive.base_url query parameters and merge them with url_fragment query parameters
    # NOTE: the url is also constructed in the react form editor, any changes here should also be done in
    # managed-interactives-authoring.tsx
    "#{library_interactive.base_url}#{url_fragment}"
  end

  # getters for inherited attributes
  def aspect_ratio_method
    inherit_aspect_ratio_method && library_interactive ? library_interactive.aspect_ratio_method : custom_aspect_ratio_method
  end

  def native_width
    inherit_native_width && library_interactive ? library_interactive.native_width : custom_native_width
  end

  def native_height
    inherit_native_height && library_interactive ? library_interactive.native_height : custom_native_height
  end

  def click_to_play
    inherit_click_to_play && library_interactive ? library_interactive.click_to_play : custom_click_to_play
  end

  def full_window
    inherit_full_window && library_interactive ? library_interactive.full_window : custom_full_window
  end

  def click_to_play_prompt
    inherit_click_to_play_prompt && library_interactive ? library_interactive.click_to_play_prompt : custom_click_to_play_prompt
  end

  def image_url
    inherit_image_url && library_interactive ? library_interactive.image_url : custom_image_url
  end

  # getters for proxied attributes
  def enable_learner_state
    library_interactive  ? library_interactive.enable_learner_state : false
  end

  def show_delete_data_button
    library_interactive ? library_interactive.show_delete_data_button : true
  end

  def has_report_url
    library_interactive ? library_interactive.has_report_url : false
  end

  def no_snapshots
    library_interactive ? library_interactive.no_snapshots : false
  end

  def thumbnail_url
    library_interactive ? library_interactive.thumbnail_url : nil
  end

  def self.portal_type
    "iframe interactive"
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

  # used for react-based authoring
  def to_authoring_hash
    hash = to_hash
    hash[:id] = id
    hash[:linked_interactive_id] = linked_interactive_id
    hash[:aspect_ratio] = aspect_ratio
    hash
  end

  def authoring_api_urls(protocol, host)
    {
      get_interactive_list: interactive_page ? Rails.application.routes.url_helpers.api_v1_get_interactive_list_url(id: interactive_page.id, protocol: protocol, host: host) : nil
    }
  end

  # returns same json as mw_interactive, used for react-based authoring
  def to_interactive_json
    # NOTE: model_library_url is missing as there is no analog
    {
      id: id,
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
      authored_state: authored_state,
      aspect_ratio: aspect_ratio,
      aspect_ratio_method: aspect_ratio_method,
      no_snapshots: no_snapshots,
      linked_interactive_id: linked_interactive_id
    }.to_json
  end

  def duplicate
    # Generate a new object with those values
    ManagedInteractive.new(self.to_hash)
    # N.B. the duplicate hasn't been saved yet
  end

  def export
    hash = to_hash()
    hash.delete(:library_interactive_id)
    hash[:library_interactive] = library_interactive ? {
      hash: library_interactive.generate_export_hash(),
      data: library_interactive.to_hash()
    } : nil
    hash
  end

  def self.import(import_hash)
    # make a shallow copy of the import_hash because we are going to modify it
    import_hash = import_hash.clone
    # save off the imported library interactive to hydrate it after the instance is created
    imported_library_interactive = import_hash[:library_interactive]
    import_hash.delete(:library_interactive)

    managed_interactive = self.new(import_hash)

    # find the existing matching library interactive or create a new one
    if imported_library_interactive
      library_interactive = LibraryInteractive.find_by_export_hash(imported_library_interactive[:hash])
      if library_interactive
        managed_interactive.library_interactive = library_interactive
      else
        library_interactive = LibraryInteractive.import(imported_library_interactive[:data])
        managed_interactive.library_interactive = library_interactive

        # save is called here in case an imported activity uses the same library interactive more than once
        # if save wasn't called then multiple copies of the same library interactive would be created
        library_interactive.save
      end
    end

    managed_interactive
  end

  # this can't be moved into BaseInteractive as enable_learner_state is defined as a method in
  # this class and that causes reportable? not to be defined correctly for outside callers
  def reportable?
    enable_learner_state
  end

  def reportable_in_iframe?
    !has_report_url
  end

  def prompt
    name
  end
end
