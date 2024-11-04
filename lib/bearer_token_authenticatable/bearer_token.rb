module BearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      token_valid?()
    end

    def authenticate!
      return fail(:invalid_token) unless token_valid?
      resource = User.find_for_token_authentication(User.token_authentication_key => token_value)
      return fail(:invalid_token) unless resource
      success!(resource)
    end

    private
    def validate(resource)
      ! resource.nil?
    end

    def token_valid?
      return false unless token_value
      return true  # TODO: Validate the string length?
    end

    def referer
      return request.env["HTTP_REFERER"]
    end

    def token_value
      header = request.headers["Authorization"]
      if header && header =~ /^Bearer (.*)$/
        $1
      else
        nil
      end
    end

  end
end

Warden::Strategies.add(:bearer_token_authenticatable, BearerTokenAuthenticatable::BearerToken)
Devise.add_module :bearer_token_authenticatable, strategy: true
