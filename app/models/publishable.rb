module Publishable
  PUB_STATUSES   = %w(draft private public archive)

  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do
      validates :publication_status, :inclusion => { :in => PUB_STATUSES }
      default_value_for :publication_status, 'draft'
      attr_accessible :publication_status, :is_official

      # * Find all public activities
      scope :public,    where(:publication_status => 'public')
      scope :newest,    order("updated_at DESC")
      scope :official,  where(:is_official => true)
      scope :community, where(:is_official => false)

      # * Find all activities for one user (regardless of publication status)
      def self.my(user)
        where(:user_id => user.id)
      end

      # * Find a users activities and the public activities
      def self.my_or_public(user)
        where("user_id =? or publication_status ='public'",user.id)
      end

      # * Find all activities visible (readable) to the given user
      def self.can_see(user)
        if user.can?(:manage, self)
          self.scoped # (like all but it keeps a relation, instead of an array)
        else
          self.my_or_public(user)
        end
      end

      def self.visible(user)
        self.can_see(user)
      end
    end
  end
end