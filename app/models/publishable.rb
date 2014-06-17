module Publishable
  PUB_STATUSES = %w(draft private public archive)
  PUB_STATUSES_OPTIONS = {
    'Public on the Web' => 'public',
    # TODO: here you can see real meaning of "private" and "draft" here.
    # We should provide better names for these (e.g. switch 'draft'
    # to 'private' and 'private' to 'link_only' or something like this).
    'Anyone with the link can run' => 'private',
    'Private' => 'draft',
    'Archive' => 'archive'
  }

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

      has_many :portal_publications, :as => :publishable, :order => :updated_at

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

  def find_portal_publication(concord_auth_portal)
    self.portal_publications.where('portal_url' =>  concord_auth_portal.publishing_url).last
  end
  alias_method :last_publication, :find_portal_publication
  def portal_publish(user,auth_portal,self_url)
    self.update_attribute('publication_status','public')
    self.portal_publish_with_token(user.authentication_token,auth_portal,self_url)
  end

  def republish_for_portal(auth_portal,self_url)
    portal_publish_with_token(auth_portal.secret,auth_portal,self_url,true)
  end

  def publication_details
    res = self.portal_publications.where(:success => true).group(:portal_url)
    counts = res.size
    return_vals = []
    dates  = res.maximum(:created_at)
    counts.keys.each do |url|
      obj = OpenStruct.new
      obj.url = url.gsub(/https?:\/\/([^\/]*).*/){ |x| $1 }
      obj.count = counts[url]
      obj.date  = dates[url].strftime('%F %R')
      return_vals << obj
    end
    return return_vals
  end

  def portal_publish_with_token(token,auth_portal,self_url,republish=false)
    # TODO: better error handling
    raise "#{self.class.name} is Not Publishable" unless self.respond_to?(:serialize_for_portal)
    url = auth_portal.publishing_url
    url = auth_portal.republishing_url if republish
    Rails.logger.info "Attempting to publish #{self.class.name} #{self.id} to #{auth_portal.url}."
    auth_token = 'Bearer %s' % token
    response = HTTParty.post(url,
      :body => self.serialize_for_portal(self_url).to_json,
      :headers => {"Authorization" => auth_token, "Content-Type" => 'application/json'})

    Rails.logger.info "Response: #{response.inspect}"
    self.portal_publications.create({
      portal_url: auth_portal.publishing_url,
      response: response.inspect,
      success: ( response.code == 201 ) ? true : false,
      publishable: self
    })

    return true if response.code == 201
    return false
  end

  def add_portal_publication(concord_auth_portal)
   found = find_portal_publication(concord_auth_portal)
   self.portal_publications.create(portal_url: concord_auth_portal.publishing_url) unless found
  end

  def remove_portal_publication(concord_auth_portal)
    found = find_portal_publication(concord_auth_portal)
    self.portal_publications.destroy(found) if found
  end

  def publish_to_portals(self_url)
    urls = self.portal_publications.where(:success => true).pluck(:portal_url).uniq
    urls.map { |url| Concord::AuthPortal.portal_for_publishing_url(url)}.each do |portal|
      self.republish_for_portal(portal,self_url)
    end
  end
end
