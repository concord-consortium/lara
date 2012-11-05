class CreateOpenResponseQuestions < ActiveRecord::Migration
  def up
    create_table :embeddable_open_responses do |t|
      t.string :name
      t.text   :prompt

      t.timestamps
    end
  end

  def down
    drop_table :embeddable_open_responses
  end
end
