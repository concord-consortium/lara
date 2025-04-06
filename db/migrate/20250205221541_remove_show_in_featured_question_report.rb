class RemoveShowInFeaturedQuestionReport < ActiveRecord::Migration[5.2]
  def up
    remove_column :embeddable_multiple_choices, :show_in_featured_question_report
    remove_column :embeddable_open_responses, :show_in_featured_question_report
    remove_column :embeddable_image_questions,:show_in_featured_question_report
    remove_column :embeddable_labbooks, :show_in_featured_question_report
    remove_column :mw_interactives, :show_in_featured_question_report
  end
  def down
    add_column :embeddable_multiple_choices, :show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_open_responses, :show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_image_questions,:show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_labbooks, :show_in_featured_question_report, :boolean, default: true
    add_column :mw_interactives, :show_in_featured_question_report, :boolean, default: true
  end
end
