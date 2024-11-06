class AddIsPredictionToEmbeddableMultipleChoiceAnswer < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choice_answers, :is_final, :boolean, :default => false
  end
end
