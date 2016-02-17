class MwInteractive < ActiveRecord::Base
  attr_accessible :name, :url, :native_width, :native_height, :save_state, :has_report_url, :click_to_play, :image_url,
                  :is_hidden

  default_value_for :native_width, 576
  default_value_for :native_height, 435

  validates_numericality_of :native_width
  validates_numericality_of :native_height

  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :interactive_item
  has_many :interactive_run_states, :as => :interactive

  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'

  after_update :update_labbook_options

  def self.string_name
    "iframe interactive"
  end

  # returns the aspect ratio of the interactive, determined by dividing the width by the height.
  # So for an interactive with a native width of 400 and native height of 200, the aspect_ratio
  # will be 2.
  def aspect_ratio
    if self.native_width && self.native_height
      return self.native_width/self.native_height.to_f
    else
      return 1.324 # Derived from the default values, above
    end
  end

  def height(width)
    return width/self.aspect_ratio
  end

  def to_hash
    # Deliberately ignoring user (will be set in duplicate)
    {
      name: name,
      url: url,
      native_width: native_width,
      native_height: native_height,
      save_state: save_state,
      has_report_url: has_report_url,
      click_to_play: click_to_play,
      image_url: image_url,
      is_hidden: is_hidden
    }
  end

  def duplicate
    # Generate a new object with those values
    new_interactive = MwInteractive.new(self.to_hash)
    # Clarify the name # Not sure why we do this
    new_interactive.name = "Copy of #{new_interactive.name}"
    return new_interactive
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
                              :save_state,
                              :has_report_url,
                              :click_to_play,
                              :image_url,
                              :is_hidden])
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

  def is_reportable
    return save_state && has_report_url
  end
end
