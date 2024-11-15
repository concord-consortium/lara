require 'builder'

module CRater
  class APIWrapper
    # Pilot environment has been recommended by ETS.
    C_RATER_URI = 'https://nlp-pilot.ets.org/crater/scoring/internal/CraterScoringServlet'
    # C-Rater supports only ISO-8859-1 AKA Latin1 encoding.
    ENCODING = 'ISO-8859-1'

    # @param url is optional, will use C_RATER_URI if missing.
    # @param api_key is optional, not all services use it.
    def initialize(client_id, username, password, url = nil, api_key = nil)
      @client_id = client_id
      @username  = username
      @password  = password
      @api_key   = api_key
      @url       = url.present? ? url : C_RATER_URI
    end

    def request_xml(item_id, response_id, response_text)
      builder = Builder::XmlMarkup.new
      xml = builder.tag!('crater-request', includeRNS: 'N') do |b|
        b.client(id: @client_id)
        b.items do
          b.item(id: item_id) do
            b.responses do
              b.response(id: response_id) do
                b.cdata!(response_text || '')
              end
            end
          end
        end
      end
      xml.encode(ENCODING)
    end

    def get_feedback(item_id, response_id, response_text)
      xml = request_xml(item_id, response_id, response_text)
      resp = HTTParty.post(@url, request_options(xml))
      # C-Rater API seems to always return HTTP 200 and error message provided in XML body.
      # This code assumes that there is only one XML structure that is correct for us (that includes score)
      # and everything else will be treated as error.
      score = get_score(resp.parsed_response)
      result = if resp.code == 200 && score
                {
                  success: true,
                  score: score
                }
              elsif resp.code == 429  # too many requests
                {
                    success: false,
                    error: I18n.t('ARG_BLOCK.NOT_AVAILABLE')
                }
              else
                {
                  success: false,
                  error: get_error(resp.parsed_response)
                }
              end
      # Always include debug information in response (code, unparsed body and headers).
      result.merge({
        response_info: {
          code: resp.code,
          headers: resp.headers.to_hash,
          body: resp.body
        }
      })
    end

    private

    def request_headers
      headers = { 'Content-Type' => "text/xml; charset=#{ENCODING}" }
      # Only send x-api-key to services that require it.
      headers['x-api-key'] = @api_key if @api_key.present?
      return headers
    end

    def request_options(body)
      {
        headers: request_headers(),
        basic_auth: {
          username: @username,
          password: @password
        },
        body: body
      }
    end

    def get_score(parsed_response)
      return nil unless parsed_response.respond_to?(:fetch) # hash expected
      score = parsed_response.fetch('crater_results', {})
                            .fetch('items', {})
                            .fetch('item', {})
                            .fetch('responses', {})
                            .fetch('response', {})
                            .fetch('score', nil)
      score.nil? ? nil : score.to_i
    end

    def get_error(parsed_response)
      return parsed_response if parsed_response.is_a?(String)
      return nil unless parsed_response.respond_to?(:fetch)
      error = parsed_response.fetch('crater_results', {})
                            .fetch('error', nil)
      if error
        "Error #{error.fetch('code', -999)}: #{error.fetch('__content__', '')}"
      else
        'Unknown error'
      end
    end
  end
end
