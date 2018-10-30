class API::APIController < ApplicationController
  layout false

  protected

  def error(message, status = 500)
    render status: status, json: {
      response_type: "ERROR",
      message: message
    }
  end

  def not_authorized(message = "Not authorized")
    error(message, 403)
  end

  public

  def show
    error("Show not configured for this resource")
  end

  def create
    error("create not configured for this resource")
  end

  def update
    error("update not configured for this resource")
  end

  def index
    error("index not configured for this resource")
  end

  def destroy
    error("destroy not configured for this resource")
  end
end
