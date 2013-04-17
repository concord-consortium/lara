class Run < ActiveRecord::Base
  attr_accessible :run_count, :user_id
  belongs_to :user

  has_many :multiple_choice_answers,
    :class_name  => 'Embeddable::MultipleChoiceAnswer',
    :foreign_key => 'run_id',
    :dependent   => :destroy

  has_many :open_response_answers,
    :class_name  => 'Embeddable::OpenResponseAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy
end
