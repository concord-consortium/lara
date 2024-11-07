class Authentication < ApplicationRecord

  belongs_to :user
  # TODO: What about token expiration?
end
