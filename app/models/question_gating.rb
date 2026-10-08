# Per-item "questions after this item start locked" setting (page-wide or the item's own section), read by
# the Activity Player from the activity export. Consumers treat a missing, null or unknown value as "none".
module QuestionGating
  extend ActiveSupport::Concern

  NONE = "none"
  VALUES = [NONE, "disable_following_on_page", "disable_following_in_section"].freeze
  TEXT_FIELDS = [:question_gating_locked_text, :question_gating_unlocked_text].freeze
  FIELDS = [:question_gating, *TEXT_FIELDS].freeze

  included do
    validates :question_gating, inclusion: { in: VALUES }
    # before_save, not before_validation: import saves with validate: false.
    before_save :normalize_question_gating
  end

  def question_gating_hash
    FIELDS.index_with { |field| self[field] }
  end

  private

  def normalize_question_gating
    self.question_gating = NONE unless VALUES.include?(question_gating)
    TEXT_FIELDS.each { |field| self[field] = nil if self[field].blank? }
  end
end
