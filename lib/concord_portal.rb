require 'omniauth-oauth2'

module Concord
  class AuthPortal
    attr_accessor :url, :id, :secret

    ConfiguredPortals = (ENV['CONFIGURED_PORTALS'] || "").upcase.split
    ExistingPortals   = {}
    AuthorizeUrl      = "/auth/concord_id/authorize"
    AccessTokenUrl    = "/auth/concord_id/access_token"

    def self.lookup(*_attr)
      attributes = ["CONCORD"].concat(_attr)
      key = attributes.join("_")
      return ENV[key]
    end

    def self.secret_for_portal(id)
      lookup(id,"CLIENT_SECRET")
    end

    def self.url_for_portal(id)
      lookup(id,"URL")
    end

    def self.for_portal(id)
      return ExistingPortals[id] if ExistingPortals[id]
      url = url_for_portal(id)
      secret = secret_for_portal(id)
      created = self.new(id,url,secret) if (id && url && secret)
      ExistingPortals[id] = created if created
      return created
    end

    def initialize(_id,_url,_secret)
      self.url    = _url
      self.secret = _secret
      self.id     = _id
    end

    def authorize_url
      "#{self.url}#{self.class::AuthorizeUrl}"
    end
    def access_token_url
      "#{self.url}#{self.class::AccessTokenUrl}"
    end

    def set_strategy_options(env)
      options = env['omniauth.strategy'].options
      client_options = options[:client_options]
      options[:client_secret] = self.secret
      options[:client_id] = self.id
      client_options[:site] = self.url
      client_options[:authorize_url] = self.authorize_url
      client_options[:access_token_url] = self.access_token_url
    end
  end
end


module OmniAuth
  module Strategies
    class ConcordPortal < OmniAuth::Strategies::OAuth2
      option :name, 'concord_portal' # Designates the callback URL, so leave it alone
      # Default, will be replaced at login time:
      option :client_options, {
        :site             => "placeholder_site",
        :authorize_url    => "placeholder_auth_url",
        :access_token_url => "placeholder_token_url"
      }
      uid { raw_info['id'] }
      info do
        {
          :email => raw_info['info']['email']
        }
      end
      extra do
        {
          :first_name => raw_info['extra']['first_name'],
          :last_name  => raw_info['extra']['last_name']
        }
      end
      def raw_info
        @raw_info ||= access_token.get("/auth/concord_id/user.json").parsed
      end
    end
  end
end
