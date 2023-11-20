class ProjectAdmin < ActiveRecord::Base
  attr_accessible :user, :project, :user_id, :project_id

  belongs_to :user
  belongs_to :project
end
