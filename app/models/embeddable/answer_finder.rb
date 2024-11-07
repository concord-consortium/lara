# This class is used for two general purposes:
#  1. To get answers for reports
#  2. To get "answers" to generate the page for the student
#
# In the case #2 the page is currently generated from the answer objects. It is not generated
# from questions and then student answers filled in. So any "question" that isn't able to have
# an answer should return itself.
#
# Currently in case #2 the AnswerFinder should only be passed the Page#page_items which means
# it shouldn't be sent MwInteractives
module Embeddable
  class AnswerFinder
    attr_accessor :run, :answer_map

    def question_key(question)
      case question
      when Embeddable::OpenResponse
        return "or_#{question.id}"
      when Embeddable::ImageQuestion
        return "iq_#{question.id}"
      when Embeddable::MultipleChoice
        return "mc_#{question.id}"
      when Embeddable::Labbook
        return "lb_#{question.id}"
      when MwInteractive
        return "mw_#{question.id}"
      when ManagedInteractive
        return "mi_#{question.id}"
      end
      return nil
    end

    def add_answer(a)
      self.answer_map[question_key(a.question)] = a
    end

    def initialize(_run=Run.create())
      self.answer_map = {}
      self.run = _run

      self.run.multiple_choice_answers.includes(:question, :answers).each { |a| add_answer(a) }
      self.run.open_response_answers.includes(:question).each { |a| add_answer(a) }
      self.run.image_question_answers.includes(:question).each { |a| add_answer(a) }
      self.run.labbook_answers.includes(:question).each { |a| add_answer(a) }
      self.run.interactive_run_states.includes(:interactive).each { |a| add_answer(a) }
    end


    def find_answer(question)
      type = answer_type(question)
      return question if type.nil?
      answer =  self.answer_map[self.question_key(question)]
      if answer.nil?
        conditions = { run: self.run, question: question }
        # If this is an ImageQuestion with an author-defined background image, we want to copy that into the answer.
        if type == Embeddable::ImageQuestionAnswer and !question.is_shutterbug? and !question.bg_url.blank?
          conditions[:image_url] = question.bg_url
        end
        answer = type.default_answer(conditions)
        self.add_answer(answer)
      end
      return answer
    end


    def answer_type(question)
      case question
      when Embeddable::OpenResponse
        return Embeddable::OpenResponseAnswer
      when Embeddable::ImageQuestion
        return Embeddable::ImageQuestionAnswer
      when Embeddable::MultipleChoice
        return Embeddable::MultipleChoiceAnswer
      when Embeddable::Labbook
        return Embeddable::LabbookAnswer
      when MwInteractive
        return InteractiveRunState
      when ManagedInteractive
        return InteractiveRunState
      end
      return nil
    end
  end
end
