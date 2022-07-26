# Labbook class represents an embeddable item, "question", authorable part of the activity page.
module Embeddable
  class Labbook < ActiveRecord::Base
    include Embeddable
    include AttachedToInteractive

    UPLOAD_ACTION = 0
    SNAPSHOT_ACTION = 1

    ACTION_OPTIONS = [
      ['Upload', UPLOAD_ACTION],
      ['Snapshot', SNAPSHOT_ACTION]
    ]

    attr_accessible :action_type, :name, :prompt, :custom_action_label, :is_hidden,
      :show_in_featured_question_report, :interactive, :hint, :is_full_width

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :embeddable_plugins, class_name: "Embeddable::EmbeddablePlugin", as: :embeddable
    has_many :interactive_pages, :through => :page_items
    has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref

    # "Answer" isn't the best word probably, but it fits the rest of names and convention.
    # LabbookAnswer is an instance related to particular activity run and user.
    has_many :answers,
      :class_name  => 'Embeddable::LabbookAnswer',
      :dependent => :destroy

    default_value_for :name, 'Labbook album' # it's used in Portal reports

    def self.name_as_param
      :embeddable_labbook
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
        show_in_featured_question_report: show_in_featured_question_report,
        # This info can be used by Portal to generate an iframe with album in teacher report.
        display_in_iframe: true,
        # These dimensions are pretty random at the moment. Labbook album doesn't look good
        # in small iframe anyway and Portal has additional limits on max width and height.
        # It would make sense to create a separate, compact view of an Labbook album for reports.
        native_width: 600,
        native_height: 500
      }
    end

    def report_service_hash
      {
        type: 'iframe_interactive',
        id: embeddable_id,
        name: name,
        show_in_featured_question_report: show_in_featured_question_report,
        display_in_iframe: true,
        width: 600,
        height: 500,
        question_number: index_in_activity
      }
    end

    def to_hash
      {
        action_type: action_type,
        name: name,
        prompt: prompt,
        custom_action_label: custom_action_label,
        is_hidden: is_hidden,
        is_full_width: is_full_width,
        hint: hint,
        show_in_featured_question_report: show_in_featured_question_report
      }
    end

    def duplicate
      self.class.new(self.to_hash)
    end

    def export
      return self.as_json(only: [
        :action_type,
        :name,
        :prompt,
        :custom_action_label,
        :is_hidden,
        :is_full_width,
        :hint,
        :show_in_featured_question_report
      ])
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

    def page_section
      # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
      page_items.count > 0 && page_items.first.section
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

    def has_interactive?
      !interactive.nil?
    end

    def interactive_is_visible?
      has_interactive? && !interactive.is_hidden?
    end

    #|                               |             |             | Interactive | Interactive | Lab Book   |
    #| Use case                      | action_type | Interactive | Visibility  | Snapshots   | Visibility |
    #|-------------------------------|-------------|-------------|-------------|-------------|------------|
    #| Regular model snapshot        | snapshot    | yes         | Shown       | yes         | Shown      |
    #| Regular model snapshot        | snapshot    | yes         | Shown       | no          | Hidden     |
    #| Regular model snapshot        | snapshot    | yes         | Hidden      | NA          | Hidden     |
    #| Dan File upload               | upload      | no          | NA          | NA          | Shown      |
    #| ITSI File upload (microscope) | upload      | yes         | Shown       | NA          | Shown      |
    #| ITSI File upload (microscope) | upload      | yes         | Hidden      | NA          | Hidden     |
    #
    # The ITSI File upload use case uses the interactive to determine whether it is visible or not.
    # this is so an ITSI author can hide and show these upload labbooks the same way they hide and show models
    #
    # NOTE: when serialize_for_portal is called at the activity level, labbooks that have their 'is_hidden' attribute
    # set are not included in the output which then overrides this truth table, however in the single page runtime
    # the 'is_hidden' attribute is ignored by the code that places the labbook below their interactive
    def show_in_runtime?
      ((action_type == UPLOAD_ACTION) && !has_interactive?) ||
      (interactive_is_visible? && !interactive.no_snapshots)
    end

    # this method assumes you've already called show_in_runtime? and it returned false
    def why_not_show_in_runtime
      return 'LABBOOK.NO_INTERACTIVE_SET' if !has_interactive?
      return 'LABBOOK.INTERACTIVE_HIDDEN' if interactive.is_hidden?
      return 'LABBOOK.INTERACTIVE_NO_SNAPSHOTS' if interactive.no_snapshots
      return 'LABBOOK.UKNOWN_REASON'
    end

    def reportable?
      show_in_runtime?
    end

    def self.update_itsi_prompts

      old_snapshot_prompt = I18n.t("LABBOOK.OLD_ITSI.SNAPSHOT_PROMPT")
      old_upload_prompt   = I18n.t("LABBOOK.OLD_ITSI.UPLOAD_PROMPT")
      new_snapshot_prompt = I18n.t("LABBOOK.ITSI.SNAPSHOT_PROMPT")
      new_upload_prompt   = I18n.t("LABBOOK.ITSI.UPLOAD_PROMPT")

      changed_snapshot_count = self.where("prompt like ?", "%#{old_snapshot_prompt[0..80]}%").update_all(prompt: new_snapshot_prompt)
      changed_upload_count = self.where("prompt like ?", "%#{old_upload_prompt[0..80]}%").update_all(prompt: new_upload_prompt)
      report_string = "updated #{changed_snapshot_count} snapshot prompts, and #{changed_upload_count} upload labbook prompts"
      Rails.logger.info report_string
    end
  end
end
