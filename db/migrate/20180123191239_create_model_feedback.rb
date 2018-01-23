class CreateModelFeedback < ActiveRecord::Migration

  def up
    create_table :embeddable_model_feedbacks do |t|
      t.string :name
      t.text   :url
      t.timestamps
    end
  end

  def down
    drop_table :embeddable_model_feedbacks
  end

end
