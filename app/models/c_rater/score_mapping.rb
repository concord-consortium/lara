class CRater::ScoreMapping < ActiveRecord::Base
  serialize :mapping
  attr_accessible :mapping, :description
  belongs_to :user
  belongs_to :changed_by, :class_name => 'User'
  
  scope :public, self.all
  scope :newest, order("updated_at DESC")

  scope :rationale,   -> { where('description LIKE ?', '%[rationale]%').order('created_at ASC') }
  scope :explanation, -> { where('description LIKE ?', '%[explanation]%').order('created_at ASC') }

  def get_feedback_text(score)
    return 'C-Rater Item ID references test model' if score == -1
    text = mapping['score' + score.to_s]
    return "No feedback text defined for score: #{score}" unless text
    text
  end

  def score0
    if !self.mapping.nil?
      @score0 = self.mapping['score0']
    end
  end
  
  def score1
    if !self.mapping.nil?
      @score1 = self.mapping['score1']
    end
  end
  
  def score2
    if !self.mapping.nil?
      @score2 = self.mapping['score2']
    end
  end
  
  def score3
    if !self.mapping.nil?
      @score3 = self.mapping['score3']
    end
  end
  
  def score4
    if !self.mapping.nil?
      @score4 = self.mapping['score4']
    end
  end
  
  def score5
    if !self.mapping.nil?
      @score5 = self.mapping['score5']
    end
  end
  
  def score6
    if !self.mapping.nil?
      @score6 = self.mapping['score6']
    end
  end
  
  def self.my(user)
    where(:user_id => user.id)
  end
  
  def self.visible(user)
    self.scoped
  end
  
end
