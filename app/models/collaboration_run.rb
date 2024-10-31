class CollaborationRun < ApplicationRecord
  # attr_accessible :user, :collaborators_data_url, :runs

  belongs_to :user
  has_many :runs

  def self.already_created?(collaborators_data_url)
    # Collaborators data endpoint URL is unambiguously defining collaboration run,
    # we don't need any other ID. It includes portal domain, collaboration
    # external ID and so on.
    self.exists?(collaborators_data_url: collaborators_data_url)
  end

  def self.lookup(collaborators_data_url)
    self.where(collaborators_data_url: collaborators_data_url).first
  end

  def is_owner?(_user)
    user == _user
  end

  def owners_run(activity)
    runs.where(user_id: user, activity_id: activity).first
  end

  # Select all the runs which do not belong to the author of the answer and which
  # are related to the same activity (it's important when there are multiple runs belonging
  # to the same user, e.g. in case of sequence).
  def collaborators_runs(activity, user)
    runs.select { |r| r.user != user && r.activity == activity }
  end

  def propagate_answer(answer)
    user     = answer.user
    question = answer.question
    collaborators_answers(question, user).each do |collab_answer|
      collab_answer.copy_answer!(answer)
    end
  end

  def disable
    runs.clear
  end

  private

  # Returns all answers to the same question that belong to other collaborators.
  # If they don't exist, they will be created. Result does not include answer
  # which belongs to the provided user.
  def collaborators_answers(question, user)
    collaborators_runs(question.activity, user).map do |run|
      finder = Embeddable::AnswerFinder.new(run)
      # find_answer creates answer when it's not found.
      finder.find_answer(question)
    end
  end

end
