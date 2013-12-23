require 'omniauth-oauth2'
module OmniAuth
  module Strategies
    class ConcordPortal < OmniAuth::Strategies::OAuth2
      option :name, 'concord_portal'
      option :portal_url, ENV['CONCORD_PORTAL_URL']
      option :client_options, {
        :site =>  options.portal_url,
        :authorize_url => "#{options.portal_url}/auth/concord_id/authorize",
        :access_token_url => "#{options.portal_url}/auth/concord_id/access_token"
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
