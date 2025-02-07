class RemoveShowInFeaturedQuestionReportFromManagedInteractive < ActiveRecord::Migration[5.2]
  def up
    remove_column :managed_interactives, :show_in_featured_question_report
  end
  def down
    add_column :managed_interactives, :show_in_featured_question_report, :boolean, default: true
  end
end
