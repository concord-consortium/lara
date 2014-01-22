class PortalPublication < ActiveRecord::Base
  attr_accessible :portal_url, :response, :success, :publishable
  # Assuming portals aren't a first-class model - representing them by their URLs

  # What got published - usually one of these, not both
  belongs_to :publishable, :polymorphic => true

  def portal_domain
    URI.parse(self.portal_url).host
  end
end
