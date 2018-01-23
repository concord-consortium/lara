class ApprovedScript < ActiveRecord::Base
  attr_accessible :name, :url, :description
  belongs_to :appoved_script
end
