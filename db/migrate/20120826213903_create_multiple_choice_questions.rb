class CreateMultipleChoiceQuestions < ActiveRecord::Migration
  def up
    create_table :embeddable_multiple_choices do |t|
      t.string :name
      t.text   :prompt

      t.timestamps
    end

    create_table :embeddable_multiple_choice_choices do |t|
      t.integer :multiple_choice_id
      t.text   :choice
      t.boolean :is_correct

      t.timestamps
    end
  end

  def down
    drop_table :embeddable_multiple_choice_choices
    drop_table :embeddable_multiple_choices
  end
end
