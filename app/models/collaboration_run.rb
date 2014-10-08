class CollaborationRun < ActiveRecord::Base
  attr_accessible :user, :collaboration_endpoint_url, :runs

  belongs_to :user
  has_many :runs

  def self.already_created?(collaboration_endpoint_url)
    # Collaboration endpoint URL is unambiguously defining collaboration run,
    # we don't need any other ID. It includes portal domain, collaboration
    # external ID and so on.
    self.exists?(collaboration_endpoint_url: collaboration_endpoint_url)
  end

  def self.lookup(collaboration_endpoint_url)
    self.where(collaboration_endpoint_url: collaboration_endpoint_url).first
  end

  def is_owner?(_user)
    user == _user
  end

  def owners_run(activity)
    runs.where(user_id: user, activity_id: activity).first
  end

  def propagate_answer(answer)
    user     = answer.user
    question = answer.question
    collaborators_answers(question, user).each do |collab_answer|
      collab_answer.copy_answer!(answer)
    end
  end

  private

  # Returns all answers to the same question that belong to other collaborators.
  # If they don't exist, they will be created. Result does not include answer
  # which belongs to the provided user.
  def collaborators_answers(question, user)
    activity = question.activity
    # Select all the runs which do not belong to the author of the answer and which
    # are related to the same activity (it's important when there are multiple runs belonging
    # to the same user, e.g. in case of sequence).
    collaborators_runs = runs.select { |r| r.user != user && r.activity == activity }
    collaborators_runs.map do |run|
      finder = Embeddable::AnswerFinder.new(run)
      # find_answer creates answer when it's not found.
      finder.find_answer(question)
    end
  end

end
