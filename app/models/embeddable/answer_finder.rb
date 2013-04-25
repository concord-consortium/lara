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
      type.by_run(run).by_question(question).first || type.create(conditions)
    end

    def answer_type(question)
      case question
      when Embeddable::OpenResponse
        return Embeddable::OpenResponseAnswer
      when Embeddable::MultipleChoice
        return Embeddable::MultipleChoiceAnswer
      end
      return nil
    end
  end
end
