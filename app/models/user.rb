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

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_admin, :is_author,
    :provider, :uid
  # attr_accessible :title, :body

  def admin?
    return is_admin
  end

  def author?
    return is_author
  end

  def self.find_for_concord_portal_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    return user if user
    email = auth.info.email || "#{Devise.friendly_token[0,20]}@example.com"

    existing_by_email = User.where(email: email)
    if existing_by_email.size > 0
      usable_email = existing_by_email.where(provider: nil, uid: nil).first
      usable_email.update_attributes(
        provider: auth.provider,
        uid: auth.uid
      )
      return usable_email if usable_email
      throw "Can't have duplicate email addresses" if existing_by_email
    end

    # return a new one:
    User.create(
      provider: auth.provider,
      uid:      auth.uid,
      email:    email,
      password: Devise.friendly_token[0,20]
    )
  end
end
