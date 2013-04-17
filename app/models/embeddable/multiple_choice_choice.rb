module Embeddable
  class MultipleChoiceChoice < ActiveRecord::Base
    attr_accessible :multiple_choice, :choice, :prompt, :is_correct

    belongs_to :multiple_choice, :class_name => "Embeddable::MultipleChoice"

    def to_hash
      hash = {
        'choice' => is_correct,
      }
      hash['prompt'] = prompt unless prompt.blank?
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
  end
end
