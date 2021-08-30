module Embeddable
  class MultipleChoice < ActiveRecord::Base

    include Embeddable


    LAYOUT_VERTICAL = "vertical"
    LAYOUT_HORIZONTAL = "horizontal"
    LAYOUT_LIKERT = "likert"


    has_many :choices,
      :class_name => 'Embeddable::MultipleChoiceChoice',
      :foreign_key => 'multiple_choice_id',
      :dependent => :destroy
    has_many :page_items, :as => :embeddable, :dependent => :destroy
    # PageItem instances are join models, so if the embeddable is gone
    # the join should go too.
    has_many :sections, through: :page_items
    has_many :interactive_pages, through: :sections

    has_many :answers,
      :class_name => 'Embeddable::MultipleChoiceAnswer',
      :foreign_key => 'multiple_choice_id',
      :dependent => :destroy

    attr_accessible :name, :prompt, :hint, :custom, :choices_attributes,
      :enable_check_answer, :multi_answer, :show_as_menu, :is_prediction, :is_full_width,
      :show_in_featured_question_report, :give_prediction_feedback, :prediction_feedback, :layout, :is_hidden
    accepts_nested_attributes_for :choices, :allow_destroy => true

    has_one :tracked_question, :as => :question, :dependent => :delete
    has_one :question_tracker, :through => :tracked_question
    has_one :master_for_tracker, :class_name => 'QuestionTracker', :as => :master_question

    default_value_for :name, "Multiple Choice Question element"
    default_value_for :prompt, "why does ..."

    def parse_choices(choice_string)
      choice_ids = choice_string.split(',').map{ |i| i.to_i } unless choice_string.blank?
      if choices && !choice_ids.blank?
        return choices.find(choice_ids)
      else
        return []
      end
    end

    def check(choice_string)
      # Takes a comma-delimited string of choice IDs, returns a hash response describing the correctness
      # of the answer described by that string.
      selected_choices = parse_choices(choice_string)
      if multi_answer
        selected_incorrect = selected_choices.select { |c| !c.is_correct }
        selected_correct = selected_choices - selected_incorrect
        actual_correct = choices.select { |c| c.is_correct }
        if selected_choices.length == 0
          # No answer
          return { prompt: 'Please select an answer before checking.'}
        elsif selected_incorrect.length > 0
          # Incorrect answer(s)
          return { prompt: selected_incorrect.map { |w| w.prompt.blank? ? "'#{w.choice}' is incorrect" : w.prompt }.join("; ") }
        elsif selected_correct.length != actual_correct.length and selected_incorrect.length == 0
          # Right answers, but not all
          return { prompt: "You're on the right track, but you didn't select all the right answers yet."}
        else selected_correct.length == actual_correct.length
          # All correct
          return { choice: true }
        end
      else
        # One answer: sending the choice to get rendered as JSON by the action
        return selected_choices.first
      end
    end

    def create_default_choices
      self.add_choice('a')
      self.add_choice('b')
      self.add_choice('c')
    end

    def add_choice(choice_name = "new choice")
      new_choice = Embeddable::MultipleChoiceChoice.create(:choice => choice_name, :multiple_choice => self)
      self.save
      new_choice
    end

    def to_hash
      # Leaving out "choices"
      {
        name: name,
        prompt: prompt,
        custom: custom,
        enable_check_answer: enable_check_answer,
        multi_answer: multi_answer,
        show_as_menu: show_as_menu,
        is_prediction: is_prediction,
        show_in_featured_question_report: show_in_featured_question_report,
        give_prediction_feedback: give_prediction_feedback,
        prediction_feedback: prediction_feedback,
        layout: layout,
        is_hidden: is_hidden,
        is_full_width: is_full_width,
        hint: hint
      }
    end

    def portal_hash
      {
        type: "multiple_choice",
        id: id,
        prompt: prompt,
        choices: choices.map{|choice| {
          id: choice.id,
          content: choice.choice,
          correct: choice.is_correct
        } },
        is_required: is_prediction,
        show_in_featured_question_report: show_in_featured_question_report
      }
    end

    def report_service_hash
      {
        type: 'multiple_choice',
        id: embeddable_id,
        prompt: prompt,
        choices: choices.map { |choice| {
          id: choice.id,
          content: choice.choice,
          correct: choice.is_correct
        }},
        show_in_featured_question_report: show_in_featured_question_report,
        question_number: index_in_activity,
        required: is_prediction
      }
    end

    def duplicate
      mc = Embeddable::MultipleChoice.new(self.to_hash)
      self.choices.each do |choice|
        mc.choices << choice.duplicate
      end
      return mc
    end

    def export
      mc_export = as_json(only:[:name,
                                :prompt,
                                :custom,
                                :enable_check_answer,
                                :multi_answer,
                                :show_as_menu,
                                :is_prediction,
                                :show_in_featured_question_report,
                                :give_prediction_feedback,
                                :prediction_feedback,
                                :layout,
                                :is_hidden,
                                :is_full_width,
                                :hint])

      mc_export[:choices] = []

      self.choices.each do |choice|
        mc_export[:choices] << choice.export
      end

      return mc_export

    end

    def is_likert
      layout == "likert"
    end

    def reportable?
      true
    end

    def page_section
      # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
      page_items.count > 0 && page_items.first.old_section
    end

    def self.import (import_hash)
      choices = import_hash[:choices]
      import_mc = self.new(import_hash.except(:choices))
      choices.each do |c|
        choice = Embeddable::MultipleChoiceChoice.new( choice: c[:choice], prompt: c[:prompt], is_correct: c[:is_correct] )
        import_mc.choices << choice
      end
      import_mc
    end

    def self.name_as_param
      :embeddable_multiple_choice
    end

    def self.display_partial
      :multiple_choice
    end

  end
end
