require 'digest/sha1'

module Publishable

  class AutoPublishIncomplete < StandardError; end

  RUNTIME_OPTIONS = {
    'Activity Player' => 'Activity Player',
    'LARA' => 'LARA'
  }

  def latest_publication_portals
    total_counts = portal_publications.group(:portal_url).count
    success_counts = portal_publications.where(:success => true).group(:portal_url).count
    group_select = "id IN (SELECT MAX(id) FROM portal_publications WHERE publishable_id = ? AND publishable_type = ? GROUP BY portal_url)"
    rows = portal_publications.select("portal_url, success, created_at, publication_hash").where([group_select, self.id, self.class.name])
    portals = []
    rows.each do |row|
      portals << {
        :url => row.portal_url,
        :domain => row.portal_url.gsub(/https?:\/\/([^\/]*).*/){ |x| $1 },
        :success => row.success,
        :total_count => total_counts[row.portal_url] || 0,
        :success_count => success_counts[row.portal_url] || 0,
        :publication_hash => row.publication_hash,
        :date => row.created_at.strftime('%F %R')
      }
    end
    portals
  end

  def find_portal_publication(concord_auth_portal)
    self.portal_publications.where('portal_url' => concord_auth_portal.publishing_url).last
  end
  alias_method :last_publication, :find_portal_publication

  def portal_publish(user,auth_portal,self_url)
    if auth_portal.is_a? String
      auth_portal = Concord::AuthPortal.portal_for_url(auth_portal)
    end

    self.update_attribute('publication_status','public')
    self.portal_publish_with_token(user.authentication_token(auth_portal.strategy_name),auth_portal,self_url)
  end

  def republish_for_portal(auth_portal,self_url,json=nil)
    if self.runtime == "Activity Player"
      # The Portal API doesn't support auth_portal.secret authentication, so we switched to using user.authentication_token
      # This means the user needs permission to publish whereas they don't with auth_portal.secret
      portal_publish_with_token(user.authentication_token(auth_portal.strategy_name),auth_portal,self_url,true,json)
    else
      portal_publish_with_token(auth_portal.secret,auth_portal,self_url,true,json)
    end
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

  def portal_publish_with_token(token, auth_portal, self_url, republish=false, json=nil)
    # TODO: better error handling
    raise "#{self.class.name} is Not Publishable" unless self.respond_to?(:serialize_for_portal)
    Rails.logger.info "Attempting to publish #{self.class.name} #{self.id} to #{auth_portal.url}."
    auth_token = 'Bearer %s' % token

    # Note that add_portal_publication will return response provided by the block itself
    # and this value will be returned from this method too.
    add_portal_publication(auth_portal) do
      if self.runtime == "Activity Player"
        json = self.serialize_for_portal_basic(self_url).to_json
        url = auth_portal.activity_player_publishing_url
        url = auth_portal.activity_player_republishing_url if republish
        success_code = republish ? 200 : 201
      else
        json = json || self.serialize_for_portal(self_url).to_json
        url = auth_portal.publishing_url
        url = auth_portal.republishing_url if republish
        success_code = 201
      end

      response = HTTParty.post(url,
        :body => json,
        :headers => { "Authorization" => auth_token, "Content-Type" => "application/json" }
      )

      {
        # response is returned from add_portal_publication too.
        response: response,
        success: response.code == success_code,
        publication_data: json
      }
    end
  end

  # This method creates a portal publication entry in the database. It expects client code to pass a block that
  # returns status of the publication (and perform it im some cases). The status should be a hash that provides
  # following properties:
  # - publication_data -> string, data that is used for publishing (usually after calling .to_json)
  # - response -> string, response from Portal (if available) or some information useful for debugging
  # - success -> boolean
  # It returns response (described above).
  def add_portal_publication(auth_portal)
    start_time = Time.now.to_f
    result = yield
    end_time = Time.now.to_f

    Rails.logger.info "Response Time: #{end_time - start_time}"
    Rails.logger.info "Response: #{result[:response].inspect}"

    publication_hash = Digest::SHA1.hexdigest(result[:publication_data])
    portal_publications.create({
      # Properties that have to be provided by the block execution result.
      sent_data: result[:publication_data],
      response: result[:response].inspect, # it works fine for actual HTTP response or any other value (e.g. string)
      success: result[:success],
      # Automatically calculated properties.
      publication_hash: publication_hash,
      portal_url: auth_portal.publishing_url,
      publishable: self,
      publication_time: (end_time - start_time) * 1000,
    })
    # update_column is necessary so this change doesn't trigger update_after
    # if update_after is triggered then a new Job will be queued and we don't need
    # to do that. This also means that updated_at column won't be changed by this
    self.update_column(:publication_hash, publication_hash)
    # Return response provided by a block execution.
    result[:response]
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

  ## auto publishing methods

  def self.included(clazz)
    clazz.class_eval do

      has_many :portal_publications, :as => :publishable, :order => :updated_at

      # all changes will be queued for auto publishing
      after_update :queue_publish

      def auto_publish_delay
        return 5
      end

      def queue_publish
        queue_auto_publish_to_portal
        queue_publish_to_report_service

        # changes to activities should trigger auto publishing of their associated sequences
        if self.respond_to?(:sequences)
          self.sequences.each { |sequence| sequence.queue_publish }
        end
      end

      def queue_auto_publish_to_portal(auto_publish_url=nil, backoff=1)

        urls = self.portal_publications.where(:success => true).pluck(:portal_url).uniq
        urls.map { |url| Concord::AuthPortal.portal_for_publishing_url(url)}.each do |portal|
          # no portals are defined in test mode
          return if portal.nil?

          # get the last time it was published (sucessfully or not)
          last_portal_publication = self.portal_publications.where('portal_url' => portal.publishing_url).last

          # skip auto publishing if never initially published
          return if last_portal_publication.nil?

          # create a new pending publication pointing at the last publication
          pending_portal_publication = PendingPortalPublication.new :portal_publication_id => last_portal_publication.id

          # try to save it - if there is an existing pending publication for this item it will throw ActiveRecord::StatementInvalid
          # because of the unique index constraint on the table
          begin
            pending_portal_publication.save!

            # if the job saved then process it
            auto_publish_url ||= Thread.current[:auto_publish_url]
            Delayed::Job.enqueue(ProcessPendingPortalPublication.new(pending_portal_publication.id, auto_publish_url, backoff), 0, (auto_publish_delay * backoff).seconds.from_now)

          rescue ActiveRecord::StatementInvalid => e
            # Perhaps there is a better way, at least on SQLite the exception type is: ActiveRecord::RecordNotUnique
            # if it is on MySQL then we can simplify this a bit
            raise e unless (e.is_a? ActiveRecord::RecordNotUnique) or /Duplicate entry/.match(e.to_s)
          end
        end
      end

      def queue_publish_to_report_service
        if ReportService.configured?
          publishable_type = self.class.name
          publishable_id = self.id
          job = SendToReportServiceJob.new(publishable_type, publishable_id, Time.now)
          Delayed::Job.enqueue(job, 0, 5.seconds.from_now)
        end
      end
    end
  end

end
