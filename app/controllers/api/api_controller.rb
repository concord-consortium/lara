class Api::ApiController < ApplicationController
  layout false

  def error(message, status = 500)
    render status: status, json: {
      response_type: "ERROR",
      message: message
    }
  end

  rescue_from CanCan::AccessDenied do
    error("Not authorized", 403)
  end

  rescue_from Api::ApiError do |e|
    error(e.message, 500)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    error(e.message, 404)
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
