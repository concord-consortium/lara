require_dependency "application_controller"

class Api::DashboardController < ApplicationController

  def remote_toc
    respond_to do |format|
      format.js do
        render :json => @activity.serialize_for_portal('blank'), :callback => params[:callback]
      end
    end
  end

end
