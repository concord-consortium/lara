class ApprovedScript < ActiveRecord::Base
  attr_accessible :name, :url, :label, :description, :version, :json_url
  validates :name, presence: true
  validates :label, format: {
    with: /^([A-Za-z0-9]+)$/,
    message: "only use letters and numbers."
  }
  validates :url, format: {
    with: /^https?:\/\//i,
    message: "include protocol (https://)"
  }
  belongs_to :appoved_script
end
