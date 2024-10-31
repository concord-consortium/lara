class TrackedQuestion < ApplicationRecord
  belongs_to :question, polymorphic: true
  belongs_to :question_tracker
  # attr_accessible :question, :question_tracker
end