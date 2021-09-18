class Api::V1::InteractiveRunStatesController < ApplicationController
  layout false
  before_filter :set_interactive_run

  skip_before_filter :verify_authenticity_token, :only => :update

  def show
    begin
      authorize! :show, @interactive_run_state

      render :json => @interactive_run_state.to_runtime_json(request.protocol, request.host_with_port)
    rescue CanCan::AccessDenied
      authorization_error("get")
    end
  end

  def update
    begin
      authorize! :update, @interactive_run_state
      @interactive_run_state.touch # update timestamp even if no data is provided

      if params.has_key?('raw_data')
        # Handle 'null' value, so interactive can reset / clear its state if necessary.
        @interactive_run_state.raw_data = params['raw_data'] == 'null' ? nil : params['raw_data']
      end
      if params.has_key?('learner_url')
        @interactive_run_state.learner_url = params['learner_url']
      end
      if params.has_key?('metadata')
        # Note that metadata is always merged, not overwritten, as multiple apps and clients can set their own metadata.
        # They still can mess each other data, but it's all coming from LARA JS env (Plugin API or Interactive API Host).
        metadata = InteractiveRunState::parse_metadata(@interactive_run_state.metadata)
        metadata.merge!(InteractiveRunState::parse_metadata(params['metadata']))
        @interactive_run_state.metadata = metadata.to_json
      end
      if @interactive_run_state.save
        render :json => @interactive_run_state.to_runtime_json(request.protocol, request.host_with_port)
      else
        render :json => { :success => false }
      end
    rescue CanCan::AccessDenied
      authorization_error("update")
    end
  end

  private

  def set_interactive_run
    @interactive_run_state = InteractiveRunState.find_by_key!(params['key'])
  end

  def authorization_error(action)
    reason = current_user ? "the owner or an admin or a collaborator" : "logged in"
    render :json => { :success => false, :message => "You are not authorized to #{action} the requested owned interactive run state because you are not #{reason}."}
  end
end
