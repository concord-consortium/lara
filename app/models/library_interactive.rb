require 'digest'

# In the UI the Managed Interactive model also called a Library Interactive
class LibraryInteractive < ApplicationRecord
  include HasAspectRatio

  has_many :managed_interactives

  default_value_for :native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates :name, presence: true

  url_format = {
    with: /\Ahttps?:\/\//i,
    message: "include protocol (http[s]://)"
  }
  optional_url_format = url_format.merge({allow_blank: true})

  validates :base_url, format: url_format
  validates :image_url, format: optional_url_format
  validates :thumbnail_url, format: optional_url_format

  validates_numericality_of :native_width
  validates_numericality_of :native_height

  before_save :update_export_hash

  def self.import(import_hash)
    library_interactive = self.new(import_hash)
    library_interactive.update_export_hash()
    library_interactive
  end

  def to_hash
    {
      aspect_ratio_method: aspect_ratio_method,
      authoring_guidance: authoring_guidance,
      base_url: base_url,
      click_to_play: click_to_play,
      click_to_play_prompt: click_to_play_prompt,
      description: description,
      enable_learner_state: enable_learner_state,
      hide_question_number: hide_question_number,
      save_interactive_state_history: save_interactive_state_history,
      full_window: full_window,
      has_report_url: has_report_url,
      image_url: image_url,
      name: name,
      native_height: native_height,
      native_width: native_width,
      no_snapshots: no_snapshots,
      show_delete_data_button: show_delete_data_button,
      thumbnail_url: thumbnail_url,
      customizable: customizable,
      authorable: authorable,
      report_item_url: report_item_url
    }
  end

  def export
    return self.as_json(only:[
      :aspect_ratio_method,
      :authoring_guidance,
      :base_url,
      :click_to_play,
      :click_to_play_prompt,
      :description,
      :enable_learner_state,
      :hide_question_number,
      :save_interactive_state_history,
      :full_window,
      :has_report_url,
      :image_url,
      :name,
      :native_height,
      :native_width,
      :no_snapshots,
      :show_delete_data_button,
      :thumbnail_url,
      :customizable,
      :authorable,
      :report_item_url
    ])
  end

  def generate_export_hash
    export = export()
    export.except!("authoring_guidance", "description", "name")
    Digest::SHA1.hexdigest(export.to_json)
  end

  def update_export_hash
    self.export_hash = self.generate_export_hash()
  end

  def use_count
    ManagedInteractive.where(library_interactive_id: self.id).count
  end

  def serializeable_id
    "#{self.class.to_s}_#{self.id}"
  end

  def self.find_by_serializeable_id(_serializeable_id)
    class_name, id = _serializeable_id.split("_")
    class_name.constantize.find_by_id(id)
  end

end
