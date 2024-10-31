class AdminEvent < ApplicationRecord
  # attr_accessible :kind, :message
  
  after_create :write_log

  protected
  def write_log
    Rails.logger.error("AdminEvent [#{self.kind}]: #{self.message}")
  end
end
