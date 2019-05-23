module ReportService

  class RunSender
    Version = "1"
    DefaultClassHash = "anonymous-run"
    DefaultUserName = "anonymous"

    extend ReportService::Base

    def question_key(answer_hash)
      question_type = answer_hash[:type] || answer_hash['type']
      question_id = answer_hash[:question_id] || answer_hash['question_id']
      RunSender.make_key(question_type, question_id)
    end

    def get_class_hash(run)
      # TODO: Maybe we look this up?
      run.class_info_url || DefaultClassHash
    end

    def username_for_run(run)
      run.user ? run.user.email : DefaultUserName
    end

    def add_meta_data(run, record, host)
      record[:version] = RunSender::Version
      record[:created] = Time.now.utc.to_s
      record[:source_key] = RunSender.make_source_key(host)
      record[:class_hash] = get_class_hash(run)
      record[:class_info_url] = run.class_info_url
      record[:user_id] = username_for_run(run)
      record[:remote_endpoint] = run.remote_endpoint
      record[:run_key] = run.key
    end

    def serialized_answer(ans, run, host)
      answer_hash = ans.portal_hash
      answer_hash[:id] = ans.answer_id
      answer_hash[:question_key] = question_key(answer_hash)
      add_meta_data(run, answer_hash, host)
      if(answer_hash[:url].blank?)
        answer_hash[:url] = ""
        answer_hash[:has_url] = false
      end
      answer_hash
    end

    def initialize(run, host)
      version = RunSender::Version
      created = Time.now.utc.to_s
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
        answers: run.answers.map { |ans| serialized_answer(ans, run, host) }
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