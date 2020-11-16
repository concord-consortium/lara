require 'omniauth-oauth2'

module Concord
  class AuthPortal

    ExistingPortals     = {}
    AuthorizeUrl        = "/auth/concord_id/authorize"
    AccessTokenUrl      = "/auth/concord_id/access_token"
    PublishingPath      = "/external_activities/publish/v2"
    RePublishingPath    = "/external_activities/republish/v2"
    APPublishingPath    = "/api/v1/external_activities"
    APRePublishingPath  = "/api/v1/external_activities/update_by_url"

    def self.configured_portal_names
      name_list = self.lookup('CONFIGURED_PORTALS') || ""
      name_list.upcase.split
    end

    def self.publishing_url
      self.lookup("PUBLISHING","URL") || "http://localhost:9000"
    end

    def self.lookup(*_attr)
      attributes = ["CONCORD"].concat(_attr)
      key = attributes.join("_")
      return ENV[key]
    end

    def self.secret_for_portal(name)
      lookup(name,"CLIENT_SECRET")
    end

    def self.client_id_for_portal(name)
      lookup(name,"CLIENT_ID")
    end

    def self.display_name_for(name)
      lookup(name,"DISPLAY_NAME") || name.titlecase
    end

    def self.portal_for_url(url)
      # URI.parse(url).host returns nil when scheme is not provided.
      host = URI(url).host || URI("http://#{url}").host
      port = URI(url).port || 80
      return nil unless host
      self.all.each_pair do |name, portal|
        portal_host =''
        begin
          portal_host = URI.parse(portal.url).host.downcase.strip
          portal_port = URI.parse(portal.url).port || 80
        rescue URI::InvalidURIError
          puts "portal.url is not valid URL : #{portal.url}"
        end
        return portal if portal_host == host.downcase.strip && portal_port == port
        # return portal if url == portal.url || (trimmed_url && trimmed_url == portal.url)
      end
      return nil # we couldn't find one.
    end

    def self.portal_for_auth_id(auth_id)
      authentication = Authentication.find_by_id(auth_id)
      authentication ? self.portal_for_strategy_name(authentication.provider) : nil
    end

    def self.portal_for_publishing_url(url)
      self.all.values.detect { |v| v.publishing_url == url }
    end

    def self.strategy_name_for_url(url)
      if portal = self.portal_for_url(url)
        return portal.strategy_name
      end
      raise "Can't find a portal for #{url}"
    end

    def self.secret_for_url(url)
      if portal = self.portal_for_url(url)
        return portal.secret
      end
      raise "Can't find a portal for #{url}"
    end

    # Should be provided as `Authorization` header value while talking to portal.
    def self.auth_token_for_url(url)
      if portal = self.portal_for_url(url)
        return portal.auth_token
      end
      raise "Can't find a portal for #{url}"
    end

    def self.for_portal_name(name)
      return ExistingPortals[name] || self.make_for_name(name)
    end

    def self.portal_for_strategy_name(name)
      self.all.values.detect{|v| v.strategy_name == name} rescue nil
    end

    def self.url_for_strategy_name(name)
      portal = self.portal_for_strategy_name(name)
      portal ? portal.url : nil
    end

    def self.default
      return self.for_portal_name(configured_portal_names.first)
    end

    def self.all_strategy_names
      self.all.values.map { |v| v.strategy_name }
    end

    def self.all
      self.configured_portal_names.each { |name| for_portal_name name }
      return ExistingPortals
    end

    def self.add(name,url,client_id,secret)
      return ExistingPortals[name] if ExistingPortals[name]
      created = self.new_strategy(name,url,client_id,secret) if (name && url && secret)
      ExistingPortals[name] = created if created
      return created
    end

    def self.make_for_name(name)
      url = lookup(name,"URL")
      secret = self.secret_for_portal(name)
      client_id = self.client_id_for_portal(name)
      return self.add(name,url,client_id,secret)
    end

    def self.new_strategy(name,url,client_id,secret)
      site = url
      auth_url = "#{url}#{AuthorizeUrl}"
      access_token_url = "#{url}#{AccessTokenUrl}"
      class_name = "cc_portal_#{name.downcase}".classify
      strategy_name = class_name.underscore
      auth_strategy =Class.new(OmniAuth::Strategies::OAuth2)
      display_name = self.display_name_for(name)
      Object.const_set(class_name,auth_strategy)
      auth_strategy.class_eval do |clz|
        @client_id = client_id
        @strategy_name = strategy_name
        @site = site
        @auth_url = auth_url
        @url = url
        @secret  = secret
        @access_token_url = access_token_url
        @display_name = display_name
        option :name, @strategy_name
        option :client_options, {
          :site             => @site,
          :authorize_url    => @auth_url,
          :access_token_url => @access_token_url
        }
        uid  { raw_info['id'] }
        info {{ :email => raw_info['info']['email'] }}
        extra do
          {
            :first_name => raw_info['extra']['first_name'],
            :last_name  => raw_info['extra']['last_name'],
            :full_name  => raw_info['extra']['full_name'],
            :username   => raw_info['extra']['username'],
            :user_id    => raw_info['extra']['user_id'],
            :roles      => raw_info['extra']['roles'] || [],
            :domain     => raw_info['extra']['domain']
          }
        end

        def raw_info
          @raw_info ||= access_token.get("/auth/concord_id/user.json").parsed
        end

        def self.id
          @client_id
        end

        def self.strategy_name
          @strategy_name
        end

        def self.secret
          @secret
        end

        def self.auth_token
          'Bearer %s' % self.secret
        end

        def self.url
          @url
        end

        def self.link_name
          @display_name
        end

        def self.publishing_url
          self.url + PublishingPath
        end

        def self.republishing_url
          self.url + RePublishingPath
        end

        def self.activity_player_publishing_url
          self.url + APPublishingPath
        end

        def self.activity_player_republishing_url
          self.url + APRePublishingPath
        end

        # This method generates the string for the strategies omniauth controller method
        # see app/controllers/user/omniauth_callbacks_controller
        def self.controller_action
          return <<-CONTROLLER_ACTION
            def #{@strategy_name}
              omniauth = request.env["omniauth.auth"]
              if extra = omniauth.extra
                session[:portal_username] = extra.username
                session[:portal_user_id]  = extra.user_id
                session[:portal_domain]   = extra.domain
              end
              @user = User.find_for_concord_portal_oauth(omniauth, current_user)
              session[:auth_id] = @user.most_recent_authentication.id
              sign_in_and_redirect @user, :event => :authentication
            end
          CONTROLLER_ACTION
        end
      end
      return auth_strategy
    end
  end
end
