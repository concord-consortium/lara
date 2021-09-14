module ReportService
  class ResourceSender
    include Sender
    Version = "1"

    def api_method
      "import_structure"
    end

    # Params:
    # +resource+:: Sequence LightweightActivity to send structure of
    # +opts+:: _ignored at the moment_
    def initialize(resource, opts={})
      version = Version
      created = Time.now.utc.to_s
      @payload = resource.serialize_for_report_service(Sender::self_url)
      type = @payload[:type]
      id = @payload[:id]
      @payload[:created] = created
      @payload[:version] = version
      @payload[:source_key] = Sender::source_key
      @payload[:tool_id] = Sender::tool_id
      @payload[:id] = ReportService::make_key(type, id)
    end

    def to_json
      @payload.to_json
    end

  end
end
