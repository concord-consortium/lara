module ReportService
  class ResourceSender
    Version = "1"

    def initialize(resource)
      @self_url = ENV['REPORT_SERVICE_SELF_URL']
      version = ResourceSender::Version
      created = Time.now.utc.to_s
      @resource_payload = resource.serialize_for_report_service(@self_url)
      type = @resource_payload[:type]
      id = @resource_payload[:id]
      @resource_payload[:created] = created
      @resource_payload[:version] = version
      @resource_payload[:source_key] = ReportService::make_source_key(@self_url)
      @resource_payload[:id] = ReportService::make_key(type, id)
    end

    def to_json()
      @resource_payload.to_json
    end

    def send()
      url = ENV['REPORT_SERVICE_URL']
      token = ENV['REPORT_SERVICE_TOKEN']
      puts "posting resource: #{@resource_payload[:type]} #{@resource_payload[:name]}"
      return HTTParty.post(
        "#{url}/import_structure",
        :body => self.to_json,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        })
    end
  end
end
