class CRater::ScoreMapping < ActiveRecord::Base
  serialize :mapping
  attr_accessible :mapping,:description
  belongs_to :user
  belongs_to :changed_by, :class_name => 'User'

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
  
  def score0=(val)
    @score0 = val
  end
  
  def score1=(val)
    @score1 = val
  end
  
  def score2=(val)
    @score2 = val
  end
  
  def score3=(val)
    @score3 = val
  end
  
  def score4=(val)
    @score4 = val
  end
  
  def score5=(val)
    @score5 = val
  end
  
  def score6=(val)
    @score6 = val
  end
end
