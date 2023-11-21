class ProjectAdmin < ActiveRecord::Base
  attr_accessible :user, :project

  belongs_to :user
  belongs_to :project
end
