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

  # Helper that generates activity report for given run and activity. When interactive is also provided, it limits
  # report to a single interactive.
  def self.report_url(run, activity, sequence = nil, interactive = nil)
    if !run || !activity
      return nil
    end

    report_link = ENV['REPORT_URL']
    self_url = ENV['REPORT_SERVICE_SELF_URL']
    if !report_link || !self_url
      return nil
    end

    uri = URI.parse(report_link)
    query = Rack::Utils.parse_query(uri.query)
    query["firebase-app"] = ENV['REPORT_SERVICE_URL'] && ENV['REPORT_SERVICE_URL'].match(/report-service-pro/) ? "report-service-pro" : "report-service-dev"
    query["sourceKey"] = ReportService::Sender::source_key

    if !run.class_info_url || !run.platform_user_id || !run.resource_link_id || !run.platform_id
      # Anonymous run or a logged in user that didn't come from Portal (e.g. teacher running a preview).
      resource_url = self_url + (sequence ? Rails.application.routes.url_helpers.sequence_path(sequence) : Rails.application.routes.url_helpers.activity_path(activity))

      query["runKey"] = run.key
      query["activity"] = resource_url
      query["resourceUrl"] = resource_url
    else
      offering_url = "#{run.class_info_url.split("/classes")[0]}/offerings/#{run.resource_link_id}"

      query["class"] = run.class_info_url
      query["offering"] = offering_url
      query["reportType"] = "offering"
      query["studentId"] = run.platform_user_id
      query["auth-domain"] = run.platform_id
    end

    if sequence
      query["activityIndex"] = sequence.activities.index(activity)
    end

    if interactive
      query["iframeQuestionId"] = interactive.embeddable_id
    end

    uri.query = Rack::Utils.build_query(query)
    uri.to_s
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
