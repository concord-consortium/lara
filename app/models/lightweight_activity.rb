class LightweightActivity < ActiveRecord::Base
  attr_accessible :name, :publication_status, :user_id, :pages, :related, :description

  belongs_to :user, :class_name => '::User' # Author

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position

  default_value_for :publication_status, 'draft'
  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  validates :publication_status, :inclusion => { :in => %w(draft private public archive) }

  def run_format
    :run_html
  end
end
