module Lightweight
  class ApplicationController < ActionController::Base

    # Borrowed methods from lib/authenticated_system.rb, which we've had little luck reaching from the engine.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      if (defined? ::User) == 'constant'
        self.current_user = ::User.find_by_id(session[:user_id]) if session[:user_id]
      else
        return false
      end
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      if (defined? ::User) == 'constant'
        authenticate_with_http_basic do |login, password|
            self.current_user = ::User.authenticate(login, password)
        end
      else
        return false
      end
    end

    # Called from #current_user.  Finally, attempt to login by an expiring token in the cookie.
    # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
    def login_from_cookie
      if (defined? ::User) == 'constant'
        user = cookies[:auth_token] && ::User.find_by_remember_token(cookies[:auth_token])
        if user && user.remember_token?
          self.current_user = user
          handle_remember_cookie! false # freshen cookie token (keeping date)
          self.current_user
        end
      else
        return false
      end
    end
  end
end
