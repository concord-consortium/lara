module Lightweight
  class LightweightActivity < ActiveRecord::Base
    attr_accessible :name, :publication_status, :user_id, :pages, :related, :description

    belongs_to :user, :class_name => '::User' # Author

    has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'Lightweight::InteractivePage', :order => :position

    has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

    def run_format
      :run_html
    end
  end
end
