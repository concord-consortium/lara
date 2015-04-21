class Embeddable::EmbeddableAnswersController < ApplicationController
  class << self; attr_accessor :embeddable_type end

  before_filter :set_answer
  before_filter :authorize_run_access

  private

  def set_answer
    @answer = self.class.embeddable_type.find(params[:id])
  end

  def authorize_run_access
    begin
      authorize!(:access, @answer.run)
    rescue
      user_id_mismatch()
      render(nothing: true, status: :unauthorized)
    end
  end

  def user_id_mismatch
    @user = current_user ? current_user.email : 'anonymous'
    @session = session.clone

    NewRelic::Agent.notice_error(RuntimeError.new("_run_user_id_mismatch"), {
      uri: request.original_url,
      referer: request.referer,
      request_params: params,
      custom_params: { user: @user }.merge(@session)
    })
  end
end
