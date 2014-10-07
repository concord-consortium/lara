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
    question = answer.question
    collaborators_answers(answer).each do |collab_answer|
      collab_answer.copy_answer!(answer)
    end
  end

  private

  # Returns all answers to the same question that belong to other collaborators.
  # If they don't exist, they will be created. Result does not include the provided answer.
  def collaborators_answers(answer)
    collaborators_runs = runs.select { |r| r.user != answer.user }
    collaborators_runs.map do |run|
      finder = Embeddable::AnswerFinder.new(run)
      # find_answer creates answer when it's not found.
      finder.find_answer(answer.question)
    end
  end

end
