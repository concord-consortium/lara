module PageHelper

  # include so append_white_list_params is available during rspec tests as the controller helpers are not automatically loaded
  include ApplicationHelper

  def redirect_to_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters = {})
    redirect_to get_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters)
  end

  def get_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters = {})
    if sequence
      append_white_list_params sequence_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters)
    else
      append_white_list_params page_with_run_path(activity_id, page_id, run_key, query_parameters)
    end
  end

end
