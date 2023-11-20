class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
         :token_authenticatable, :bearer_token_authenticatable
  devise :omniauthable, :omniauth_providers => Concord::AuthPortal.all_strategy_names

  has_many :activities, :class_name => LightweightActivity
  has_many :sequences
  has_many :runs
  has_many :imports
  has_many :glossaries, order: :name
  has_many :admined_projects, :class_name => ProjectAdmin, include: [:project]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :is_admin, :is_author, :first_name, :last_name,
    :provider, :uid, :authentication_token, :api_key, :has_api_key
  # attr_accessible :title, :body

  has_many :authentications, :dependent => :delete_all

  self.token_authentication_key = "api_key"

  def self.find_for_token_authentication(condition)
    self.where(condition).first
  end


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
      auth = authentications.find_last_by_provider provider
    else
      auth = most_recent_authentication
    end
    auth ? auth.token : nil
  end

  def self.get_random_password
    Devise.friendly_token[0,20]
  end

  def self.possibly_make_user_author(auth, user)
    # assign the author role if user is author on portal but not locally
    # the chain of tests are needed because under rspec the auth object is generated inside OmniAuth and it does not include the extra info
    if !user.is_author && (auth.respond_to? :extra) && (auth.extra.roles.include? "author")
      user.is_author = true
      user.save
    end
  end

  def self.find_for_concord_portal_oauth(auth, signed_in_resource=nil)
    authentication = Authentication.find_by_provider_and_uid auth.provider, auth.uid
    if authentication
      # update the authentication token for this user to make sure it stays fresh
      authentication.update_attribute(:token, auth.credentials.token)
      possibly_make_user_author(auth, authentication.user)
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

    possibly_make_user_author(auth, user)
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
  end

  def has_api_key
    return api_key.present?
  end

  def has_api_key=(newvalue)
    if newvalue == "1"
      if api_key.blank?
        update_attribute(:api_key, UUIDTools::UUID.random_create.to_s)
      end
    else
      update_attribute(:api_key, nil)
    end
  end

  def user_links
    links = []
    if can? :manage, User
      links.push({text: "User Admin", path: Rails.application.routes.url_helpers.admin_users_path})
    end
    if can? :manage, Project
      links.push({text: "Projects", path: Rails.application.routes.url_helpers.projects_path})
    end
    if can? :manage, QuestionTracker
      links.push({text: "QuestionTrackers", path: Rails.application.routes.url_helpers.question_trackers_path})
    end
    if can? :manage, ApprovedScript
      links.push({text: "Plugins", path: Rails.application.routes.url_helpers.approved_scripts_path})
    end
    if can? :manage, User
      links.push({text: "Failed Runs", path: Rails.application.routes.url_helpers.dirty_runs_path})
    end
    if can? :manage, CRater::ScoreMapping
      links.push({text: "Score Mappings", path: Rails.application.routes.url_helpers.c_rater_score_mappings_path})
    end
    if can? :manage, LibraryInteractive
      links.push({text: "Library Interactives", path: Rails.application.routes.url_helpers.library_interactives_path})
    end
    if can? :manage, Setting
      links.push({text: "Settings", path: Rails.application.routes.url_helpers.settings_path})
    end

    return links
  end

end
