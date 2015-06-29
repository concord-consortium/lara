# Labbook class represents an embeddable item, "question", authorable part of the activity page.
module Embeddable
  class Labbook < ActiveRecord::Base
    include Embeddable

    UPLOAD_ACTION = 0
    SNAPSHOT_ACTION = 1

    ACTION_OPTIONS = [
      ['Upload', UPLOAD_ACTION],
      ['Snapshot', SNAPSHOT_ACTION]
    ]

    attr_accessible :action_type, :name, :prompt,
      :custom_action_label, :is_hidden,
      :interactive_type, :interactive_id, :interactive,
      :interactive_select_value

    attr_writer :interactive_select_value

    before_validation :parse_interactive_select_value

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :interactive_pages, :through => :page_items

    belongs_to :interactive, :polymorphic => true

    # "Answer" isn't the best word probably, but it fits the rest of names and convention.
    # LabbookAnswer is an instance related to particular activity run and user.
    has_many :answers,
             :class_name  => 'Embeddable::LabbookAnswer'

    default_value_for :name, 'Labbook album' # it's used in Portal reports

    def self.name_as_param
      :embeddable_labbook
    end

    def self.human_description
      "Labbook album"
    end

    def self.portal_type
      # Note that the same type is also used by MwInteractive.
      'iframe interactive'
    end

    def portal_id
      # We have to add prefix to ID to make sure that there are no conflicts
      # between various LARA classes using the same portal type (e.g. MwInteractive).
      "#{self.class.name}_#{id}"
    end

    # Question interface.
    def portal_hash
      {
        # This is ridiculous, but portal sometimes uses 'iframe interactive' and sometimes 'iframe_interactive'...
        type: self.class.portal_type.gsub(' ', '_'),
        id: portal_id,
        name: name,
        # This info can be used by Portal to generate an iframe with album in teacher report.
        display_in_iframe: true,
        # These dimensions are pretty random at the moment. Labbook album doesn't look good
        # in small iframe anyway and Portal has additional limits on max width and height.
        # It would make sense to create a separate, compact view of an Labbook album for reports.
        native_width: 600,
        native_height: 500
      }
    end

    def to_hash
      {
        action_type: action_type,
        name: name,
        prompt: prompt,
        custom_action_label: custom_action_label
      }
    end

    def duplicate
      self.class.new(self.to_hash)
    end

    def export
      return self.as_json(only: [:action_type, :name, :prompt, :custom_action_label])
    end

    def self.import(import_hash)
      self.new(import_hash)
    end
    # End of question interface.

    def is_upload?
      action_type == UPLOAD_ACTION
    end

    def is_snapshot?
      action_type == SNAPSHOT_ACTION
    end


    def page
      # Return first page (note that in practice it's impossible that this model has more
      # than one page, even though it's many-to-many association).
      interactive_pages.first
    end

    def possible_interactives
      # Only the visible_interactives should be used when selecting an interactive
      return page.visible_interactives if page
      return []
    end

    def interactives_for_select
      # Because interactive is ploymorphic association, normal AR optinons
      # for select don't work.
      possible_interactives.each_with_index.map do |pi,i|
        ["#{pi.class.model_name.human} (#{i+1})", make_interactive_select_value(pi)]
      end
    end

    def interactive_select_value
      return @interactive_select_value if @interactive_select_value
      return make_interactive_select_value(interactive) if interactive
    end

    def make_interactive_select_value(interactive)
      "#{interactive.id}-#{interactive.class.name}"
    end

    def default_interactive
      possible_interactives.first
    end

    def action_label
      return custom_action_label unless custom_action_label.blank?
      case action_type
        when UPLOAD_ACTION
          I18n.t('UPLOAD_IMAGE')
        when SNAPSHOT_ACTION
          I18n.t('TAKE_SNAPSHOT')
      end
    end

    def is_connected?
      !interactive.nil?
    end

    def show_in_runtime?
      is_connected?
    end

    private
    def parse_interactive_select_value
      if interactive_select_value
        id, model = self.interactive_select_value.split('-')
        self.interactive = Kernel.const_get(model).send(:find, id) rescue nil
      end
    end

  end
end
