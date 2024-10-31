# encoding: UTF-8

class QuestionTracker < ApplicationRecord
  # attr_accessible :master_question, :questions, :name, :description, :user
  
  belongs_to :master_question, polymorphic: true
  has_many :tracked_questions

  def self.list_tracked_questions(user)
    # TODO: search by user, other criteria?
    self.order('id DESC').limit(100)
  end

  def correct_type(question)
    question.is_a? self.master_question.class
  end

  def questions
    tracked_questions.map { |tq| tq.question }
  end

  def add_question(question)
    if (correct_type(question))
      unless questions.include? question
        self.tracked_questions.create(question: question, question_tracker: self)
        return true
      end
    end
    return false
  end

  def new_question()
    new_q = master_question.duplicate
    new_q.save
    add_question(new_q)
    return new_q
  end

  def remove_question(question)
    tracked_questions.where(question_id: question, question_type: question.class.name).each { |q| q.delete }
    tracked_questions.reload
    question.reload
  end

  def type
    master_question.class.model_name.human
  end

  def use_count
    tracked_questions.length
  end

  def master_question_info
    return I18n.translate("QUESTION_TRACKER.MASTER_QUESTION.NOT_DEFINED") unless master_question
    return "#{master_question_type} : #{master_question_id} : #{master_question.prompt}"
  end
end
