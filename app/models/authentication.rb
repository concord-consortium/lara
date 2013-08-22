class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :token

  belongs_to :user
end
