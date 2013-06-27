class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable
         # confirmable is waiting on a glitch: http://stackoverflow.com/q/15207154/306084
  devise :omniauthable, :omniauth_providers => [:concord_portal]

  has_many :activities, :class_name => LightweightActivity
  has_many :sequences

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_admin, :is_author,
    :provider, :uid, :authentication_token
  # attr_accessible :title, :body

  def admin?
    return is_admin
  end

  def author?
    return is_author
  end

  def self.find_for_concord_portal_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    email = auth.info.email || "#{Devise.friendly_token[0,20]}@example.com"
    unless user
      existing_by_email = User.where(email: email)
      if existing_by_email.size > 0
        user = existing_by_email.where(provider: nil, uid: nil).first
        throw "Can't have duplicate email addresses" unless user
        user.update_attributes(
          provider: auth.provider,
          uid: auth.uid,
          authentication_token: auth.credentials.token
        )
        return user
      else
        # make a new user:
        user = User.create(
          provider: auth.provider,
          uid:      auth.uid,
          email:    email,
          password: Devise.friendly_token[0,20]
        )
      end
    end
    # update the authentication token:
    user.update_attribute(:authentication_token, auth.credentials.token);
    user
  end
end
