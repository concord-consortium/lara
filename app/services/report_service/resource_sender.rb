module ReportService
  class ResourceSender
    include Sender
    Version = "1"

    def initialize(resource)
      getParamsFromEnv
      version = Version
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
      super.send('import_structure')
    end
  end
end
