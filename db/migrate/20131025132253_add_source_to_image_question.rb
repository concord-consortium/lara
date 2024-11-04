class AddSourceToImageQuestion < ActiveRecord::Migration
  def change
    # Existing ImageQuestions will become Shutterbug questions
    add_column :embeddable_image_questions, :bg_source, :string, default: 'Shutterbug'
  end
end
