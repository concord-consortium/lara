class SubmitDirtyAnswersJob < Struct.new(:run_id, :start_time)
  def enqueue(job)
    job.run_at = 30.seconds.from_now
  end

  def send_to_report_service(run)
    # only send answers which are 'dirty':
    sender = ReportService::RunSender.new(run, {send_all_answers: false})
    response = sender.send
    Rails.logger.info(
      "Run sent to report service, success: #{response.success?}, " +
      "num_answers: #{run.answers.count}, #{run.run_info_string}, " +
      "response: #{response.code} #{response.message} #{response.body}"
    )
    if response.success?
      run.set_status_flag(Run::SentToReportServiceStatusFlag)
    else
      run.clear_status_flag(Run::SentToReportServiceStatusFlag)
      run.abort_job_and_requeue(run.run_info_string)
    end
  end

  def perform
    run = Run.find(run_id)
    # Find array of dirty answers and send them to the portal
    da = run.dirty_answers
    return if da.empty?
    run.send_to_portal(da, start_time)
    # if there is a report service configured send run data there
    send_to_report_service(run) if ReportService::configured?
    # We're only cleaning the same set we sent to the portal and report service
    run.set_answers_clean(da)
    run.reload
    if run.dirty_answers.empty?
      run.mark_clean
    else
      # I'm not sure about using this method here, because it raises an error when the
      # "problem" may just be that (a) new dirty answer(s) were submitted between the
      # send_to_portal call and the check here.
      run.abort_job_and_requeue
    end
  end
end
