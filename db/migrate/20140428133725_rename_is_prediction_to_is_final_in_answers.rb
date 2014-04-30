class RenameIsPredictionToIsFinalInAnswers < ActiveRecord::Migration
  def table_names
    %w[
      embeddable_open_response_answers
      embeddable_image_question_answers
    ]
  end 
  def index_name(answer_table)
    return answer_table.gsub("_answers","_id").gsub("embeddable_","")
  end

  def up
    table_names.each do |table_name|
      begin
        remove_index table_name, index_name(table_name)
      rescue
      end
      change_table table_name do |t|
        t.rename :is_prediction, :is_final
      end
      add_index table_name, index_name(table_name)
    end
  end

  def down
    table_names.each do |table_name|
      begin
        remove_index table_name, index_name(table_name)
      rescue
      end
      change_table table_name do |t|
        t.rename :is_final, :is_prediction
      end
      add_index table_name, index_name(table_name)
    end
  end
end
