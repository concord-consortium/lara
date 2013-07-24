class Embeddable::ImageQuestionAnswer < ActiveRecord::Base
  attr_accessible :answer_text, :image_url, :run, :question, :annotation

  belongs_to :question,
    :class_name => 'Embeddable::ImageQuestion',
    :foreign_key => "image_question_id"

  belongs_to :run

  scope :by_question, lambda { |q|
    {:conditions => { :image_question_id => q.id}}
  }

  scope :by_run, lambda { |r|
    {:conditions => { :run_id => r.id }}
  }

  delegate :prompt,  :to  => :question
  delegate :name,    :to  => :question

  after_update :send_to_portal

  def question_index
    if self.run && self.run.activity
      self.run.activity.questions.index(self.question) + 1
    else
      nil
    end
  end

  def has_snapshot?
    !image_url.blank?
  end

  def portal_hash
    {
      "type" => "image_question",
      "question_id" => question.id.to_s,
      "answer" => answer_text,
      "image_url" => image_url,
      "annotation" => annotation
    }
  end

  def send_to_portal
    run.send_to_portal(self) if run
  end

  def to_json
    portal_hash.to_json
  end

end
