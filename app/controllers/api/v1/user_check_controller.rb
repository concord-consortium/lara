class Api::V1::UserCheckController < ApplicationController
  layout false

  skip_before_filter :verify_authenticity_token, :only => :index

  def index
    render :json => {user: current_user}
  end
end