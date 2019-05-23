module ReportService

  class RunSender
    Version = "1"

    def hostname(url)
      hostname = url.gsub(/https?:\/\/([^\/]+)/,'\1')
      hostname.gsub(/(\.|\/)+/,'_')
    end

    def answer_key(url, answer_hash)
      question_type = answer_hash[:type] || answer_hash['type']
      question_id = answer_hash[:question_id] || answer_hash['question_id']
      key ="#{hostname(url)}-#{question_type}-#{question_id}"
      key = key.gsub(/(\.|\/)+/,'_')
      puts key
      key
    end

    def get_class_hash(run)
      # TODO: Maybe we look this up?
      run.class_info_url || "anonymous-run"
    end

    def initialize(run, host)
      version = RunSender::Version
      created = Time.now.utc.to_s
      url = "#{host}#{Rails.application.routes.url_helpers.run_path(run)}"
      class_hash = get_class_hash(run)
      username = run.user ? run.user.email : 'anonymous'
      key = run.key
      hostname = hostname(host)
      @run_payload = {
        key: key,
        user_id: username,
        class_hash: class_hash,
        url: url,
        host: host,
        version: version,
        created: created,
        class_info_url: run.class_info_url,
        run_count: run.run_count,
        created_at: run.created_at,
        updated_at: run.updated_at,
        activity_id: run.activity_id,
        remote_id: run.remote_id,
        page_id: run.page_id,
        remote_endpoint: run.remote_endpoint,
        sequence_id: run.sequence_id,
        sequence_run_id: run.sequence_run_id,
        collaboration_run_id: run.collaboration_run_id,
        answers: run.answers.map do |ans|
          answer_hash = ans.portal_hash
          key = answer_key(host, answer_hash)
          puts key
          answer_hash[:id] = ans.answer_id
          answer_hash[:host] = host
          answer_hash[:key] = key
          answer_hash[:run_key] = run.key
          answer_hash[:class_hash] = class_hash
          answer_hash[:user_id] = username
          answer_hash[:version] = version
          answer_hash[:created] = created
          if(answer_hash[:url].blank?)
            answer_hash[:url] = "#{url}/key"
            answer_hash[:has_url] = false
          end
          answer_hash
        end
      }

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