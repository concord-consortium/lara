module ReportService
  KeyRegex = /(\.|\/)+/
  UrlRegex = /https?:\/\/([^\/]+)/
  KeyReplacement = "_"
  KeyJoiner = "-"
  ErrorMessage = <<-EOF
    Configure with REPORT_SERVICE_TOKEN, REPORT_SERVICE_URL,
    and REPORT_SERVICE_SELF_URL
  EOF

  class NotConfigured < StandardError
    def initialize(msg=ErrorMessage)
      super(msg)
    end
  end

  def self.make_key(*values)
    key = values.join(KeyJoiner)
    key.gsub(KeyRegex, KeyReplacement)
  end

  def self.make_source_key(url)
    url.gsub(UrlRegex, '\1')
  end

  def self.configured?()
    ENV['REPORT_SERVICE_TOKEN'].present? &&
    ENV['REPORT_SERVICE_URL'].present? &&
    ENV['REPORT_SERVICE_SELF_URL'].present?
  end


  module Sender

    def self.self_url
      raise ReportService::NotConfigured.new unless ReportService::configured?
      ENV['REPORT_SERVICE_SELF_URL']
    end

    def self.report_service_url
      raise ReportService::NotConfigured.new unless ReportService::configured?
      ENV['REPORT_SERVICE_URL']
    end

    def self.report_service_token
      raise ReportService::NotConfigured.new unless ReportService::configured?
      ENV['REPORT_SERVICE_TOKEN']
    end

    def self.tool_id
      if ENV['REPORT_SERVICE_TOOL_ID'].present?
        ENV['REPORT_SERVICE_TOOL_ID']
      else
        self.self_url
      end
    end

    def self.source_key
      ReportService::make_source_key(tool_id)
    end

    def api_endpoint
      "#{Sender::report_service_url}/#{api_method}"
    end

    def send()
      HTTParty.post(
        api_endpoint,
        :body => to_json,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{Sender::report_service_token}"
        }
      )
    end

    def payload_hash
      Digest::SHA1.hexdigest(to_json)
    end

  end

end
