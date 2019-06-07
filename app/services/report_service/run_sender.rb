module ReportService
  class RunSender
    Version = "1"
    DefaultClassHash = "anonymous-run"
    DefaultUserEmail = "anonymous"

    def get_resource_url(run, host)
      if run.sequence_id
        "#{host}#{Rails.application.routes.url_helpers.sequence_path(run.sequence_id)}"
      else
        "#{host}#{Rails.application.routes.url_helpers.activity_path(run.activity_id)}"
      end
    end

    def add_meta_data(run, record, host)
      record[:version] = RunSender::Version
      record[:created] = Time.now.utc.to_s
      record[:source_key] = ReportService::make_source_key(host)
      record[:resource_url] = get_resource_url(run, host)
      record[:class_hash] = run.class_hash
      record[:class_info_url] = run.class_info_url
      record[:user_email] = run.user ? run.user.email : DefaultUserEmail
      record[:remote_endpoint] = run.remote_endpoint
      record[:run_key] = run.key
    end

    def serialized_answer(ans, run, host)
      answer_hash = ans.report_service_hash
      add_meta_data(run, answer_hash, host)
      answer_hash
    end

    def serlialized_answers(run, host)
      age_threshold_seconds = 0.25
      modified_answers = run.answers.select do
        |a| a.updated_at - a.created_at > age_threshold_seconds
      end
      modified_answers.map do |ans|
        begin
          serialized_answer(ans, run, host)
        rescue => e
          Rails.logger.error "Failed to serialize answer: #{e}"
          nil
        end
      end
      .compact
    end

    def initialize(run, host)
      url = "#{host}#{Rails.application.routes.url_helpers.run_path(run)}"
      @run_payload = {
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
        answers: serlialized_answers(run, host)
      }
      add_meta_data(run, @run_payload, host)
    end

    def to_json()
      @run_payload.to_json
    end

    def send(url, token)
      HTTParty.post(
        "#{url}/import_run",
        :body => self.to_json,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }
      )
    end
  end
end
