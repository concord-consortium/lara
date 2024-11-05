class AddIndexesGetFasterProfit < ActiveRecord::Migration[5.1]
  def change
    # Not big wins, but seldom written-to, so probably harmless
    add_index :projects, :theme_id
    add_index :sequences, :user_id
    add_index :sequences, :theme_id
    add_index :sequences, :project_id
    add_index :lightweight_activities, :changed_by_id
    add_index :lightweight_activities, :theme_id
    add_index :lightweight_activities, :project_id

    # Great idea
    add_index :page_items, :interactive_page_id
    add_index :page_items, [:embeddable_id, :embeddable_type]
    add_index :sequence_runs, :sequence_id
    add_index :sequence_runs, :user_id
    add_index :embeddable_multiple_choice_choices, :multiple_choice_id

    add_index :embeddable_image_question_answers, :image_question_id
    add_index :embeddable_multiple_choice_answers, :multiple_choice_id
    add_index :embeddable_multiple_choice_answers, :run_id
    add_index :embeddable_open_response_answers, :open_response_id
    add_index :embeddable_open_response_answers, :run_id

    add_index :video_sources, :video_interactive_id

    add_index :lightweight_activities_sequences, :lightweight_activity_id, :name => 'index_activities_sequence_join_by_activity'
    add_index :lightweight_activities_sequences, :sequence_id, :name => 'index_activities_sequence_join_by_sequence'

    # Tread lightly
    add_index :runs, :key
    add_index :runs, :activity_id
    add_index :runs, :user_id
    add_index :runs, [:user_id, :activity_id]
    add_index :runs, [:user_id, :remote_id, :remote_endpoint]
    add_index :runs, :remote_endpoint
    add_index :runs, :sequence_id
    add_index :runs, :sequence_run_id
  end
end
