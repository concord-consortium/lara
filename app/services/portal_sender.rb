module PortalSender

  class Protocol
    VersionRoutePrefix = "protocol_version"
    Versions =[
        { name: "1", serialization_method_name: :response_for_portal_1_0 },
        { name: "0", serialization_method_name: :response_for_portal     }
    ]

    PortalProtocolMap = {}

    def self.instance(endpoint)
      uri = URI.parse(endpoint)
      portal_key   = "#{uri.host}:#{uri.port}"
      PortalProtocolMap[portal_key] ||= self.new
      PortalProtocolMap[portal_key]
    end

    def initialize()
      @last_try      = 12.months.ago
      @version_index = 0
    end

    def version
      Versions[@version_index]
    end

    def retry_interval
      20.minutes
    end

    def assume_latest_version
      @version_index = 0
    end

    def versioned_endpoint(endpoint)
      # special case the oldest portals that didn't have an versioned endpoint
      if @version_index == oldest_version_index
        return endpoint
      end
      "#{endpoint}/#{PortalSender::Protocol::VersionRoutePrefix}/#{self.version[:name]}"
    end

    def post_answers(answers, remote_endpoint, start_time = nil)
      assume_latest_version if @last_try < retry_interval.ago
      try_again = true
      while try_again
        @last_try = Time.now
        serialized_data = self.send serialization_method_name, answers, start_time
        response = HTTParty.post(
            versioned_endpoint(remote_endpoint), {
            body: serialized_data,
            headers: {
                "Authorization" => Concord::AuthPortal.auth_token_for_url(remote_endpoint),
                "Content-Type" => 'application/json'
            }
        })
        return true if response.success?
        Rails.logger.error "URL: #{versioned_endpoint(remote_endpoint)} |#{response.code}| #{response.message}"
        try_again = can_try_earlier_version?
        next_version!
      end
      return false
    end


    def oldest_version_index
      return Versions.length() -1
    end


    def can_try_earlier_version?
      @version_index < oldest_version_index
    end

    def next_version!
      if can_try_earlier_version?
        @version_index = @version_index + 1
      end
    end

    def serialization_method_name
      version[:serialization_method_name]
    end

    def arrayify_answers(answer)
      if answer.kind_of? Array
        answer
      else
        [answer]
      end
    end

    ################################################
    # Version 1.0 of the protocol
    ################################################
    def response_for_portal_1_0(_answer, start_time = nil)
      answers  = arrayify_answers(_answer)

      data_for_portal = {
        answers: answers.map { |ans| ans.portal_hash },
        version: "1",
        lara_end: Time.now.utc.to_s,
      }

      # lara_start is used by the portal to track how long the latency is from a change
      # made by a student in LARA to when that changes is fully available in the portal.
      if start_time
        data_for_portal[:lara_start] = start_time.utc.to_s
      end

      return data_for_portal.to_json
    end

    ################################################
    # Version 0.0 of the protocol
    ################################################
    def response_for_portal(_answer, start_time = nil)
      answers = arrayify_answers(_answer)
      answers.map { |ans| ans.portal_hash }.to_json
    end

  end

end
