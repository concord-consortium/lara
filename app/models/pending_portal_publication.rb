class PendingPortalPublication < ActiveRecord::Base
  attr_accessible :portal_publication_id, :auto_publish_url

  belongs_to :portal_publication
end
