class ProjectAdmin < ApplicationRecord
  # attr_accessible :user, :project

  belongs_to :user
  belongs_to :project
end
