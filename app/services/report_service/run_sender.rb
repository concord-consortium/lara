module ReportService

  class RunSender
    include Sender

    Version = "1"
    DefaultUserEmail = "anonymous"

    def get_resource_url(run)
      if run.sequence_id
        "#{self_url}#{Rails.application.routes.url_helpers.sequence_path(run.sequence_id)}"
      else
        "#{self_url}#{Rails.application.routes.url_helpers.activity_path(run.activity_id)}"
      end
    end

    def add_meta_data(run, record)
      record[:version] = RunSender::Version
      record[:created] = Time.now.utc.to_s
      record[:source_key] = ReportService::make_source_key(self_url)
      record[:resource_url] = get_resource_url(run)
      record[:class_hash] = run.class_hash
      record[:class_info_url] = run.class_info_url
      record[:user_email] = run.user ? run.user.email : DefaultUserEmail
      record[:remote_endpoint] = run.remote_endpoint
      record[:run_key] = run.key
    end

    def serialized_answer(ans, run)
      answer_hash = ans.report_service_hash
      add_meta_data(run, answer_hash)
      answer_hash
    end

    def serlialized_answers(run)
      age_threshold_seconds = 0.25
      modified_answers = run.answers.select do |a|
        a.updated_at - a.created_at > age_threshold_seconds
      end
      # Send only the dirty answers, onless forced to send them all.
      unless @send_all_answers
        modified_answers.select! do |a|
          a.dirty?
        end
      end
      modified_answers.map do |ans|
        begin
          serialized_answer(ans, run)
        rescue => e
          Rails.logger.error "Failed to serialize answer: #{e}"
          nil
        end
      end
      .compact
    end

    def api_method
      "import_run"
    end

    def initialize(run, send_all_answers=false)
      @send_all_answers = send_all_answers
      url = "#{self_url}#{Rails.application.routes.url_helpers.run_path(run)}"
      @payload = {
        id: run.key,
        url: url,
        run_count: run.run_count,
        created_at: run.created_at,
        updated_at: run.updated_at,
        activity_id: run.activity_id,
        remote_id: run.remote_id,
        page_id: run.page_id,
        sequence_id: run.sequence_id,
        sequence_run_id: run.sequence_run_id,
        collaboration_run_id: run.collaboration_run_id,
        answers: serlialized_answers(run)
      }
      add_meta_data(run, @payload)
    end

    def to_json
      @payload.to_json
    end

  end
end
