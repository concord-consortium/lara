class RemoveTeacherEditionQuestionWrapperDefaultValues < ActiveRecord::Migration
  class Plugin < ApplicationRecord
  end

  def valid_json(json) 
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
  end

  def change
    Plugin.all.each do |p|
      if p.author_data.present? && valid_json(p.author_data)
        author_data = JSON.parse(p.author_data)
        change_required = false
        if author_data["questionWrapper"]
          if author_data["questionWrapper"]["correctExplanation"] === "correct"
            author_data["questionWrapper"]["correctExplanation"] = ""
            change_required = true
          end
          if author_data["questionWrapper"]["distractorsExplanation"] === "distractor"
            author_data["questionWrapper"]["distractorsExplanation"] = ""
            change_required = true
          end
          if author_data["questionWrapper"]["exemplar"] === "exemplar"
            author_data["questionWrapper"]["exemplar"] = ""
            change_required = true
          end
          if author_data["questionWrapper"]["teacherTip"] === "teacherTip"
            author_data["questionWrapper"]["teacherTip"] = ""
            change_required = true
          end

          if change_required
            p.author_data = author_data.to_json
            p.save
          end
        end
      end
    end
  end
end
