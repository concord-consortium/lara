class Api::V1::DashboardController < ApplicationController

  # Controller for HAS Dashboard (aka HASBot C-Rater) report.


  # `#runs` returns the json representing report data for students.
  # Params:
  #   page_id: The page to report on.
  #   endpoint_urls: The runs (students) to report on.
  #   submissions_created_after: Only report on runs updated after this timestamp. (optional)
  #   callback: Client side javascript method to invoke. Sent by jquery `jsonP` request. TODO: stop using jsonP.
  def runs
    page_id = params[:page_id]
    endpoint_urls = params[:endpoint_urls] || []
    submissions_created_after = params[:submissions_created_after]
    dashboard = DashboardRunlist.new(endpoint_urls, page_id, submissions_created_after)
    render json: dashboard.to_json, callback: params[:callback]
  end

  # `#toc` returns the json structure of the offering used in the table of contents in the report.
  # Params:
  #   runnable_type: one of either 'sequences' or 'activities'. Clients extract this from the portal run urls.
  #   runnable_id: the id of the sequence or activity to display TOC data for.
  #   callback: Client side javascript method to invoke. Sent by jquery `jsonP` request. TODO: stop using jsonP.
  def toc
    callback      = params[:callback]
    runnable_type = params[:runnable_type]
    runnable_id   = params[:runnable_id]
    runnable = nil
    case runnable_type
      when 'activities'
        runnable = LightweightActivity.find(runnable_id)
      when 'sequences'
        runnable = Sequence.find(runnable_id)
    end
    toc = DashboardToc.new(runnable)
    render json: toc.to_hash, callback: callback
  end
end