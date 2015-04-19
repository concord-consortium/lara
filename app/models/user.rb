class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
  devise :omniauthable, :omniauth_providers => Concord::AuthPortal.all_strategy_names

  has_many :activities, :class_name => LightweightActivity
  has_many :sequences
  has_many :runs
  has_many :imports

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_admin, :is_author,
    :provider, :uid, :authentication_token
  # attr_accessible :title, :body

  has_many :authentications

  # access cancan outside of current_user
  # see https://github.com/ryanb/cancan/wiki/ability-for-other-users
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability

  def admin?
    return is_admin
  end

  def author?
    return is_author
  end

  def most_recent_authentication
    authentications.order("updated_at desc").first
  end

  def authentication_token(provider=nil)
    # TODO: token expiration
    auth = nil
    if provider
      auth = authentications.find_by_provider provider
    end
    auth ||= most_recent_authentication
    auth ? auth.token : nil
  end

  def self.get_random_password
    Devise.friendly_token[0,20]
  end

  def self.find_for_concord_portal_oauth(auth, signed_in_resource=nil)
    authentication = Authentication.find_by_provider_and_uid auth.provider, auth.uid
    if authentication
      # update the authentication token for this user to make sure it stays fresh
      authentication.update_attribute(:token, auth.credentials.token)
      return authentication.user
    end

    # there is no authentication for this provider and uid
    # see if we should create a new authentication for an existing user
    # or make a whole new user
    email = auth.info.email || "#{Devise.friendly_token[0,20]}@example.com"

    # the devise validatable model enforces unique emails, so no need find_all
    existing_user_by_email = User.find_by_email email

    if existing_user_by_email
      if existing_user_by_email.authentications.find_by_provider auth.provider
        throw "Can't have duplicate email addresses: #{email}. " +
              "There is an user with an authentication for this provider #{auth.provider} " +
              "and the same email already."
      end
      # There is no authentication for this provider and user
      user = existing_user_by_email
    else
      # no user with this email, so make a new user with a random password
      user = User.create(
        email:    email,
        password: User.get_random_password
      )
    end
    # create new authentication for this user that we found or created
    user.authentications.create(
      provider: auth.provider,
      uid:      auth.uid,
      token:    auth.credentials.token
    )
    user
  end

  # Return a list of providers for this user by checking previous authorizations
  # and available runs
  def auth_providers
    ( authentications.map { |auth| auth.provider.upcase } + runs.map { |run| run.get_auth_provider } ).uniq
  end

  # Delete session data before we logout.
  # Removes run_key, and user info from the browsers session.
  # So that logged-in indicator will match actual logged in status.
  def clear_session_data(rack_session)
   rack_session.delete "portal_username"
   rack_session.delete "portal_user_id"
   rack_session.delete "portal_domain"
   rack_session.delete "user_return_to" 
   rack_session.delete "response_key"
  end
end
