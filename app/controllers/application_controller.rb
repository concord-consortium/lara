class ApplicationController < ActionController::Base
  # For modal edit windows. Source: https://gist.github.com/1456815
  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }
end
