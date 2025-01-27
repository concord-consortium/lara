class ChangeIsFeaturedToShowInFeaturedQuestionReport < ActiveRecord::Migration[5.1]
  def up
    remove_column :embeddable_multiple_choices, :is_featured
    remove_column :embeddable_open_responses, :is_featured
    remove_column :embeddable_image_questions, :is_featured
    remove_column :embeddable_labbooks, :is_featured
    remove_column :mw_interactives, :is_featured

    add_column :embeddable_multiple_choices, :show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_open_responses, :show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_image_questions,:show_in_featured_question_report, :boolean, default: true
    add_column :embeddable_labbooks, :show_in_featured_question_report, :boolean, default: true
    add_column :mw_interactives, :show_in_featured_question_report, :boolean, default: true
  end

  def down
    remove_column :embeddable_multiple_choices, :show_in_featured_question_report
    remove_column :embeddable_open_responses, :show_in_featured_question_report
    remove_column :embeddable_image_questions, :show_in_featured_question_report
    remove_column :embeddable_labbooks, :show_in_featured_question_report
    remove_column :mw_interactives, :show_in_featured_question_report

    add_column :embeddable_multiple_choices, :is_featured, :boolean, default: false
    add_column :embeddable_open_responses, :is_featured, :boolean, default: false
    add_column :embeddable_image_questions,:is_featured, :boolean, default: false
    add_column :embeddable_labbooks, :is_featured, :boolean, default: false
    add_column :mw_interactives, :is_featured, :boolean, default: false
  end
end
