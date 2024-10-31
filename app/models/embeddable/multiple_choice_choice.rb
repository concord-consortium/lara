module Embeddable
  class MultipleChoiceChoice < ApplicationRecord
    # attr_accessible :multiple_choice, :choice, :prompt, :is_correct

    belongs_to :multiple_choice, :class_name => "Embeddable::MultipleChoice"

    has_and_belongs_to_many :answers,
      :class_name => 'Embeddable::MultipleChoiceAnswer',
      :join_table => 'mc_answer_choices',
      :foreign_key => 'choice_id',
      :association_foreign_key => 'answer_id'

    def to_hash
      hash = {
        'choice' => is_correct,
      }
      if prompt && multiple_choice.custom
        hash['prompt'] = prompt
      end
      hash
    end

    def to_json
      MultiJson.dump(self.to_hash)
    end

    def page
      if multiple_choice && !multiple_choice.interactive_pages.empty?
        return multiple_choice.interactive_pages.last
      else
        return nil
      end
    end

    def duplicate
      return Embeddable::MultipleChoiceChoice.new( choice: self.choice, prompt: self.prompt, is_correct: self.is_correct )
    end
    
    def export
      self.as_json(only:[:choice,:prompt,:is_correct])
    end 
  end
end
