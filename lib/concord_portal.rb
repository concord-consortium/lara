require 'omniauth-oauth2'
module OmniAuth
  module Strategies
    class ConcordPortal < OmniAuth::Strategies::OAuth2
      option :name, 'concord_portal' # Designates the callback URL, so leave it alone
      site_key = 'HAS_STAGING'
      # Default, will be replaced at login time:
      option :client_options, {
        :site =>  ENV["CONCORD_#{site_key}_URL"],
        :authorize_url => "#{ENV["CONCORD_#{site_key}_URL"]}/auth/concord_id/authorize",
        :access_token_url => "#{ENV["CONCORD_#{site_key}_URL"]}/auth/concord_id/access_token"
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
