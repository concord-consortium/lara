class AddToggleInfoAssessmentOptionToInteractivePages < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :toggle_info_assessment, :boolean, :default => false, after: :show_info_assessment
  end
end
