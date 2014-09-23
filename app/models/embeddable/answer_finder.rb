module Embeddable
  class AnswerFinder
    attr_accessor :run

    def initialize(_run=Run.create())
      self.run = _run
    end

    def find_answer(question)
      type = answer_type(question)
      return question if type.nil?
      conditions = { :run => self.run, :question => question }
      # If this is an ImageQuestion with an author-defined background image, we want to copy that into the answer.
      if type == Embeddable::ImageQuestionAnswer and !question.is_shutterbug? and !question.bg_url.blank?
        conditions[:image_url] = question.bg_url
      end
      type.by_run(run).by_question(question).first || type.create(conditions)
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
