class PendingPortalPublication < ActiveRecord::Base
  attr_accessible :portal_publication_id

  belongs_to :portal_publication
end
