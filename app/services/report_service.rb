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
    make_key(url.gsub(UrlRegex, '\1'))
  end

  def self.configured?()
    ENV['REPORT_SERVICE_TOKEN'].present? &&
    ENV['REPORT_SERVICE_URL'].present? &&
    ENV['REPORT_SERVICE_SELF_URL'].present?
  end


  module Sender
    def to_json()
      @payload.to_json
    end

    def send(endpoint)
      HTTParty.post(
        "#{@report_service_url}/#{endpoint}",
        :body => self.to_json,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@report_service_token}"
        }
      )
    end

    def getParamsFromEnv
      raise ReportService::NotConfigured.new unless ReportService::configured?
      @self_url = ENV['REPORT_SERVICE_SELF_URL']
      @report_service_url = ENV['REPORT_SERVICE_URL']
      @report_service_token = ENV['REPORT_SERVICE_TOKEN']
    end
  end

end
