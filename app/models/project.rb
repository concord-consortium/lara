class Project < ActiveRecord::Base
  attr_accessible :footer, :logo, :title, :url
  has_many :sequences
  has_many :lightweight_activities
end
