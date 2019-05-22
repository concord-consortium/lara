module ReportService

  class RunSender
    Version = "1"

    def answer_key(host, answer_hash)
      return "#{host.gsub(/\./,'_')}-#{answer_hash[:type]}-#{answer_hash[:id]}"
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
          answer_hash[:id]
          answer_hash[:host] = host
          answer_hash[:key] = answer_key(host, answer_hash)
          answer_hash[:run_key] = run.key
          answer_hash[:class_hash] = class_hash
          answer_hash[:user_id] = username
          answer_hash[:version] = version
          answer_hash[:created] = created
          if(answer_hash[:url].blank?)
            answer_hash[:url] = "http://#{host}/"
          end
          answer_hash
        end
      }

    end

    def to_json()
      @run_payload.to_json
    end

    def send(url, token)
      puts "posting run: #{@run_payload[:key]}"
      result = HTTParty.post(
        "#{url}/import_run",
        :body => self.to_json,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        })
      puts "post result: #{result}"
    end

  end
end