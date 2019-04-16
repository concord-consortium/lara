module PageHelper

  def redirect_to_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters = {})
    redirect_to get_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters)
  end

  def get_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters = {})
    if sequence
      sequence_page_with_run_path(sequence, activity_id, page_id, run_key, query_parameters)
    else
      page_with_run_path(activity_id, page_id, run_key, query_parameters)
    end
  end

end