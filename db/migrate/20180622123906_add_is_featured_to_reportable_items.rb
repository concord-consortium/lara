class AddIsFeaturedToReportableItems < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :is_featured, :boolean, :default => false
    add_column :embeddable_open_responses, :is_featured, :boolean, :default => false
    add_column :embeddable_image_questions, :is_featured, :boolean, :default => false
    add_column :embeddable_labbooks, :is_featured, :boolean, :default => false
    add_column :mw_interactives, :is_featured, :boolean, :default => false
  end
end
