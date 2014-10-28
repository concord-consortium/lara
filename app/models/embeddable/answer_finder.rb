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
      when MwInteractive
        return "if_#{question.id}"
      when InteractiveRunState::QuestionStandin
        return question.interactive ? "if_#{question.interactive.id}" : nil
      end
      return nil
    end

    def add_answer(a)
      self.answer_map[question_key(a.question)] = a
    end

    def initialize(_run=Run.create())
      self.answer_map = {}
      self.run = _run
      mc_answers = self.run.multiple_choice_answers.includes(:question, :answers).each { |a| add_answer(a) }
      or_answers = self.run.open_response_answers.includes(:question).each   { |a| add_answer(a) }
      iq_answers = self.run.image_question_answers.includes(:question).each  { |a| add_answer(a) }
      if_answers = self.run.interactive_run_states.includes(:interactive).each { |a| add_answer(a) }
    end


    def find_answer(question)
      type = answer_type(question)
      return question if type.nil?
      answer =  self.answer_map[self.question_key(question)] 
      if answer.nil?
        conditions = { :run => self.run, :question => question }
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
      when MwInteractive
        return InteractiveRunState
      end
      return nil
    end
  end
end
