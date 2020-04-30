class LibraryInteractive < ActiveRecord::Base
  include HasAspectRatio

  DEFAULT_CLICK_TO_PLAY_PROMPT = "Click here to start the interactive."

  attr_accessible :aspect_ratio_method, :authoring_guidance, :base_url, :click_to_play, :click_to_play_prompt, :description,
                  :enable_learner_state, :full_window, :has_report_url, :image_url, :name, :native_height, :native_width,
                  :no_snapshots, :show_delete_data_button, :thumbnail_url

  default_value_for :native_width, ASPECT_RATIO_DEFAULT_WIDTH
  default_value_for :native_height, ASPECT_RATIO_DEFAULT_HEIGHT

  validates :name, presence: true

  url_format = {
    with: /^https?:\/\//i,
    message: "include protocol (http[s]://)"
  }
  optional_url_format = url_format.merge({allow_blank: true})

  validates :base_url, format: url_format
  validates :image_url, format: optional_url_format
  validates :thumbnail_url, format: optional_url_format

  validates_numericality_of :native_width
  validates_numericality_of :native_height

end
