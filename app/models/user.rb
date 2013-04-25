class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable
         # confirmable is waiting on a glitch: http://stackoverflow.com/q/15207154/306084

  has_many :activities, :class_name => LightweightActivity

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_admin, :is_author
  # attr_accessible :title, :body

  def admin?
    return is_admin
  end

  def author?
    return is_author
  end
end
