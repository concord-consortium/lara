class AddMultipleChoiceAnswerChoice < ActiveRecord::Migration[5.1]
  def up
    remove_column :embeddable_multiple_choice_answers, :answer_ids
    remove_column :embeddable_multiple_choice_answers, :answer_texts


    create_table :mc_answer_choices, :id => false do |t|
        t.references :answer
        t.references :choice
    end

    add_index :mc_answer_choices, [:answer_id, :choice_id]
    add_index :mc_answer_choices, [:choice_id, :answer_id]
  end

  def down
    drop_table :mc_answer_choices
    add_column :embeddable_multiple_choice_answers, :answer_ids, :text
    add_column :embeddable_multiple_choice_answers, :answer_texts, :text
  end

end
