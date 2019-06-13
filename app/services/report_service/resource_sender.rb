module ReportService
  class ResourceSender
    include Sender
    Version = "1"

    def api_method
      "import_structure"
    end

    def initialize(resource)
      version = Version
      created = Time.now.utc.to_s
      @payload = resource.serialize_for_report_service(self_url)
      type = @payload[:type]
      id = @payload[:id]
      @payload[:created] = created
      @payload[:version] = version
      @payload[:source_key] = ReportService::make_source_key(self_url)
      @payload[:id] = ReportService::make_key(type, id)
    end

    def to_json
      @payload.to_json
    end

  end
end
