class TrackedQuestion < ApplicationRecord
  belongs_to :question, polymorphic: true
  belongs_to :question_tracker
end