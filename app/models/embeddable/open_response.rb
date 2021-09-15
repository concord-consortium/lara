module Embeddable
  class OpenResponse < ActiveRecord::Base
    include Embeddable


    attr_accessible :name, :prompt, :hint, :is_prediction, :show_in_featured_question_report, :give_prediction_feedback, :prediction_feedback,
      :default_text, :is_hidden, :is_full_width

    # PageItem instances are join models, so if the embeddable is gone the join should go too.
    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :sections, through: :page_items
    has_many :interactive_pages, through: :sections
    has_many :answers,
      :class_name  => 'Embeddable::OpenResponseAnswer',
      :foreign_key => 'open_response_id',
      :dependent => :destroy

    has_one :tracked_question, :as => :question, :dependent => :delete
    has_one :question_tracker, :through => :tracked_question
    has_one :master_for_tracker, :class_name => 'QuestionTracker', :as => :master_question

    default_value_for :prompt, "why does ..."

    def to_hash
      {
        name: name,
        prompt: prompt,
        is_prediction: is_prediction,
        show_in_featured_question_report: show_in_featured_question_report,
        give_prediction_feedback: give_prediction_feedback,
        prediction_feedback: prediction_feedback,
        default_text: default_text,
        is_hidden: is_hidden,
        is_full_width: is_full_width,
        hint: hint
      }
    end

    def portal_hash
      {
        type: "open_response",
        id: id,
        prompt: prompt,
        is_required: is_prediction,
        show_in_featured_question_report: show_in_featured_question_report
      }
    end

    def report_service_hash
      {
        type: 'open_response',
        id: embeddable_id,
        prompt: prompt,
        show_in_featured_question_report: show_in_featured_question_report,
        question_number: index_in_activity,
        required: is_prediction
      }
    end

    def duplicate
      return Embeddable::OpenResponse.new(self.to_hash)
    end

    def reportable?
      true
    end

    def self.name_as_param
      :embeddable_open_response
    end

    def self.display_partial
      :open_response
    end

    def export
      return self.as_json(only:[:name,
                                :prompt,
                                :is_prediction,
                                :show_in_featured_question_report,
                                :give_prediction_feedback,
                                :prediction_feedback,
                                :default_text,
                                :is_hidden,
                                :is_full_width,
                                :hint])
    end

    def self.import (import_hash)
      return self.new(import_hash)
    end

    # SettingsProviderFunctionality extends the functionality of duplicate, export and import using alias_method_chain.
    # So these methods needs to be visible to the SettingsProviderFunctionality.
    include CRater::SettingsProviderFunctionality
  end
end
