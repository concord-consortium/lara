class PublicationsController < ApplicationController
  before_action :setup
  # simplest object for rendering our views.  TODO: move elsewhere?
  class PortalStatus
    def initialize(concord_portal,publishable)
      @portal = concord_portal
      @publishable = publishable
    end

    def published?
      return @publishable.portal_publications.detect { |pp| pp.portal_url == @portal.publishing_url }
    end

    def publishable?(user)
      return user.authentications.detect { |p| p.provider == @portal.strategy_name }
    end
    def status(user)
      last_publication = @publishable.last_publication(@portal)
      if last_publication
        return "publish_ok" if last_publication.success
        return "publish_fail" if @publishable.portal_publications.where("portal_url = ? AND success = ?", @portal.publishing_url, true).size > 0
        return "add_to_fail"
      end
      return "publishable" if publishable?(user)
    end
    def date
      last = @publishable.last_publication(@portal)
      return 'not published' unless last
      return last.created_at.strftime("%F %R")
    end
    def id
      @portal.id
    end
    def name
      @portal.strategy_name
    end
    def url
      @portal.url
    end
  end

  def show_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render json: { html: render_to_string('show_status')}, content_type: 'text/json' }
      format.html
    end
  end

  def autopublishing_status
    status = {
      last_publication_hash: @publishable.publication_hash,
      latest_publication_portals: @publishable.latest_publication_portals
    }
    render json: status, content_type: 'text/json'
  end

  def remove_portal
    @portal = find_portal
    @publishable.remove_portal_publication(@portal)
    redirect_to show_status
  end

  def add_portal
    # TODO: we must not forget to actually publish this later, see publis_activity_path(activity)
    @portal = find_portal
    @message = ''
    req_url = "#{request.protocol}#{request.host_with_port}"
    @publishable.portal_publish(current_user,@portal,req_url)
    redirect_to action: 'show_status'
  end

  def publish
    req_url = "#{request.protocol}#{request.host_with_port}"
    @publishable.publish_to_portals(req_url)
    redirect_to action: 'show_status'
  end

  def publish_to_other_portals
    redirect_to action: 'show_status'
  end

  private
  def find_portal(portal_url=nil)
    portal_url ||= params['portal_url']
    Concord::AuthPortal.portal_for_url(portal_url)
  end

  def setup
    type = params['publishable_type'].constantize
    id = params['publishable_id']
    @publishable = type.find(id)
    @portals = Concord::AuthPortal.all.values.map { |v| PortalStatus.new(v, @publishable) }
  end
end

