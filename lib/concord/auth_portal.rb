require 'omniauth-oauth2'

module Concord
  class AuthPortal

    ExistingPortals   = {}
    AuthorizeUrl      = "/auth/concord_id/authorize"
    AccessTokenUrl    = "/auth/concord_id/access_token"

    def self.configured_portal_names
      name_list = self.lookup('CONFIGURED_PORTALS') || ""
      name_list.upcase.split
    end

    def self.publishing_url
      self.lookup("publishing","url") || "http://localhost:9000"
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

    def self.url_for_portal(name)
      lookup(name,"URL")
    end
    
    def self.portal_for_url(url)
      self.all.each_pair do |name,portal|
        return portal if url == portal.url
      end
      return nil # we couldn't find one.
    end

    def self.strategy_name_for_url(url)
      if portal = self.portal_for_url(url)
        return portal.strategy_name
      end
      raise "Can't find a portal for #{url}"
    end
    def self.for_portal_name(name)
      return ExistingPortals[name] || self.make_for_name(name)
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

    def self.make_for_name(name)
      url = self.url_for_portal(name)
      secret = self.secret_for_portal(name)
      client_id = self.client_id_for_portal(name)
      created = self.new_strategy(name,url,client_id,secret) if (name && url && secret)
      ExistingPortals[name] = created if created
      return created
    end

    def self.new_strategy(name,url,client_id,secret)
      site = url
      auth_url = "#{url}#{AuthorizeUrl}"
      access_token_url = "#{url}#{AccessTokenUrl}"
      class_name = "cc_portal_#{name.downcase}".classify
      strategy_name = class_name.underscore
      auth_strategy =Class.new(OmniAuth::Strategies::OAuth2)
      Object.const_set(class_name,auth_strategy)
      auth_strategy.class_eval do |clz|
        @client_id = client_id
        @strategy_name = strategy_name
        @site = site
        @auth_url = auth_url
        @url = url
        @secret  = secret
        @access_token_url = access_token_url
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
            :last_name  => raw_info['extra']['last_name']
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

        def self.url
          @url
        end
        # This method generates the string for the strategies omniauth controller method
        # see app/controllers/user/omniauth_callbacks_controller
        def self.controller_action
          return <<-CONTROLLER_ACTION
            def #{@strategy_name}
              omniauth = request.env["omniauth.auth"]
              @user = User.find_for_concord_portal_oauth(omniauth, current_user)
              sign_in_and_redirect @user, :event => :authentication
            end
          CONTROLLER_ACTION
        end
      end
      return auth_strategy
    end
  end
end
