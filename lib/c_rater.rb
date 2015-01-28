require 'builder'

class CRater
  # Pilot environment has been recommended by ETS.
  C_RATER_URI = 'https://nlp-pilot.ets.org/crater/scoring/internal/CraterScoringServlet'
  # C-Rater supports only ISO-8859-1 encoding.
  ENCODING = 'iso-8859-1'

  def initialize(client_id, username, password, url = nil)
    @client_id = client_id
    @username  = username
    @password  = password
    @url       = url || C_RATER_URI
  end

  def request_xml(item_id, response_id, response_text)
    builder = Builder::XmlMarkup.new
    xml = builder.tag!('crater-request', includeRNS: 'N') do |b|
      b.client(id: @client_id)
      b.items do
        b.item(id: item_id) do
          b.responses do
            b.response(id: response_id) do
              b.cdata!(response_text)
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
    score = get_score_from_resp(resp.parsed_response)
    result = if resp.code == 200 && score
               {
                 success: true,
                 score: score
               }
             else
               {
                 success: false
               }
             end
    # Always include debug information in response (code, unparsed body and headers).
    result.merge({
      code: resp.code,
      headers: resp.headers,
      body: resp.body
    })
  end

  private

  def request_options(body)
    {
      headers: {
        'Content-Type' => "application/xml; charset=#{ENCODING}"
      },
      basic_auth: {
        username: @username,
        password: @password
      },
      body: body
    }
  end

  def get_score_from_resp(parsed_response)
    return nil unless parsed_response.respond_to?(:fetch) # hash expected
    score = parsed_response.fetch('crater_results', {})
                           .fetch('items', {})
                           .fetch('item', {})
                           .fetch('responses', {})
                           .fetch('response', {})
                           .fetch('score', nil)
    score.nil? ? nil : score.to_i
  end
end
