# In the UI the ManagedInteractive model is called Library Interactive
# There is also a LibraryInteractive model which are the items in the
# interactive library
class ManagedInteractive < ApplicationRecord
  include BaseInteractive
  include Embeddable
  include HasAspectRatio


  default_value_for :custom_native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :custom_native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates_numericality_of :custom_native_width
  validates_numericality_of :custom_native_height

  belongs_to :library_interactive

  has_one :page_item, as: :embeddable, dependent: :destroy
  # PageItem is a join model; if this is deleted, that instance should go too

  has_many :primary_linked_items, through: :page_item
  has_many :secondary_linked_items, through: :page_item

  has_one :section, through: :page_item
  has_one :interactive_page, through: :section
  has_many :interactive_run_states, as: :interactive, dependent: :destroy

  has_many :embeddable_plugins, class_name: "Embeddable::EmbeddablePlugin", as: :embeddable
  has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref

  has_one :labbook, as: :interactive, class_name: 'Embeddable::Labbook'

  belongs_to :linked_interactive, polymorphic: true
  belongs_to :legacy_ref, polymorphic: true

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

  def hide_question_number
    inherit_hide_question_number && library_interactive  ? library_interactive.hide_question_number : custom_hide_question_number
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

  def report_item_url
    library_interactive ? library_interactive.report_item_url : nil
  end

  def self.portal_type
    "iframe interactive"
  end

  # to_hash is used by the export and duplicate methods here, and the create_page_item, update_page_item,
  # and generate_item_json methods in controllers/api/v1/interactive_pages_controller.rb
  def to_hash
    # Deliberately ignoring user (will be set in duplicate)
    {
      library_interactive_id: library_interactive_id,
      library_interactive_name: library_interactive ? library_interactive.name : nil,
      library_interactive_base_url: library_interactive ? library_interactive.base_url : nil,
      name: name,
      url_fragment: url_fragment,
      authored_state: authored_state,
      is_hidden: is_hidden,
      is_half_width: is_half_width,
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
      custom_image_url: custom_image_url,
      linked_interactives: linked_interactives_list,
      linked_interactive_item_id: linked_interactive_item_id,
      inherit_hide_question_number: inherit_hide_question_number,
      custom_hide_question_number: custom_hide_question_number
    }
  end

  def to_authoring_preview_hash
    # in preview mode we look like an interactive
    hash = to_interactive
    hash[:linked_interactives] = linked_interactives_list
    hash
  end

  # to_interactive is used by the to_authoring_preview_hash method above. The to_authoring_preview_method
  # is deprecated. It is not used in LARA 2 and we plan to remove it when LARA 2 is moved to production.
  #
  # It differs from to_hash by including:
  # id, url, native_width, native_height, enable_learner_state, show_delete_data_button, has_report_url,
  # click_to_play, click_to_play_prompt, full_window, image_url, aspect_ratio, aspect_ratio_method,
  # no_snapshots, linked_interactive_id, linked_interactive_type
  #
  # It also differs from to_hash by not including:
  # library_interactive_id, url_fragment, inherit_aspect_ratio_method, custom_aspect_ratio_method,
  # inherit_native_width, custom_native_width, inherit_native_height, custom_native_height,
  # inherit_click_to_play, custom_click_to_play, inherit_full_window, custom_full_window,
  # inherit_click_to_play_prompt, custom_click_to_play_prompt, inherit_image_url, custom_image_url,
  # linked_interactives, inherit_hide_question_number, custom_question_number

  def to_interactive
    # NOTE: model_library_url is missing as there is no analog
    {
      id: id,
      name: name,
      url: url,
      native_width: native_width,
      native_height: native_height,
      enable_learner_state: enable_learner_state,
      hide_question_number: hide_question_number,
      show_delete_data_button: show_delete_data_button,
      has_report_url: has_report_url,
      click_to_play: click_to_play,
      click_to_play_prompt: click_to_play_prompt,
      full_window: full_window,
      image_url: image_url,
      is_hidden: is_hidden,
      is_half_width: is_half_width,
      show_in_featured_question_report: show_in_featured_question_report,
      authored_state: authored_state,
      aspect_ratio: aspect_ratio,
      aspect_ratio_method: aspect_ratio_method,
      no_snapshots: no_snapshots,
      linked_interactive_id: linked_interactive_id,
      linked_interactive_type: linked_interactive_type
    }
  end

  def duplicate
    # Remove linked_interactives from the hash since it can't be mapped to a database column like the other
    # properties in the hash can, and so causes an error when we try to create the duplicate interactive.
    # Also remove the library interactive name and base url which are only used by the authoring interface.
    new_interactive_hash = self.to_hash.except!(:linked_interactives, :library_interactive_name, :library_interactive_base_url)
    # Generate a new object with those values
    ManagedInteractive.new(new_interactive_hash)
    # N.B. the duplicate hasn't been saved yet
  end

  def report_service_hash
    result = super # BaseInteractive#report_service_hash
    if legacy_ref
      embeddable_class = legacy_ref_type.constantize
      result[:legacy_id] = "#{embeddable_class.to_s.demodulize.underscore}_#{legacy_ref_id}"
    end
    result
  end

  def export
    # Remove linked_interactives from the hash so we don't export linked embeddables. The export method
    # in LaraSerializationHelper provides special handling for this value. See comment there for more.
    # Also remove the library interactive name and base url which are only used by the authoring interface.
    hash = to_hash().except!(:linked_interactives, :library_interactive_name, :library_interactive_base_url)
    hash.delete(:library_interactive_id)
    hash[:library_interactive] = library_interactive ? {
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
      potential_new_li = LibraryInteractive.new(imported_library_interactive[:data])
      potential_new_li_export_hash = potential_new_li.generate_export_hash()
      library_interactive = LibraryInteractive.find_by_export_hash(potential_new_li_export_hash)
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
    enable_learner_state && !hide_question_number
  end

  def reportable_in_iframe?
    !has_report_url
  end

  def prompt
    name
  end
end
