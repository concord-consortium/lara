class Api::V1::UserCheckController < ApplicationController
  layout false

  skip_before_action :verify_authenticity_token, :only => :index

  def index
    render :json => {user: current_user ? current_user.attributes.slice('id', 'email', 'is_admin', 'is_author') : nil}
  end
end