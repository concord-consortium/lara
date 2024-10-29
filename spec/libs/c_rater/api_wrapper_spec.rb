require 'spec_helper'

describe CRater::APIWrapper do
  let(:client_id)     { 'concord' }
  let(:username)      { 'cc' }
  let(:password)      { 'password' }
  let(:protocol)      { 'https://'}
  let(:url)           { 'c-rater.fake.url.org' }
  let(:item_id)       { 'fake_item_id' }
  let(:response_id)   { 123 }
  let(:response_text) { 'response abc xyz' }
  let(:score)         { 2 }
  let(:api_key)       { 'fakekey' }
  let(:xml_req_spec) do
    xml = <<-EOS
      <crater-request includeRNS="N">
        <client id="#{client_id}"/>
        <items>
          <item id="#{item_id}">
            <responses>
              <response id="#{response_id}">
                <![CDATA[#{response_text}]]>
              </response>
            </responses>
          </item>
        </items>
      </crater-request>
    EOS
    process_xml(xml)
  end
  let(:xml_resp_spec) do
    xml = <<-EOS
      <crater-results>
        <tracking id="12345"/>
        <client id="#{client_id}"/>
        <items>
          <item id="#{item_id}">
            <responses>
              <response id="#{response_id}" score="#{score}" concepts="3,6" realNumberScore="2.62039"
                confidenceMeasure="0.34574">
                <advisorylist>
                  <advisorycode>101</advisorycode>
                </advisorylist>
              </response>
            </responses>
          </item>
        </items>
      </crater-results>
    EOS
    process_xml(xml)
  end

  let(:crater) { CRater::APIWrapper.new(client_id, username, password, "#{protocol}#{url}", api_key)}

  def process_xml(xml_string)
    # Remove new lines and unnecessary whitespaces
    xml_string.squish.gsub('> <', '><')
  end

  describe '#request_xml' do
    subject { crater.request_xml(item_id, response_id, response_text) }
    # Yes, this test isn't flexible at all. However it should be good enough, as it's very unlikely we ever change
    # form of the request.
    it { is_expected.to eql(xml_req_spec) }
  end

  describe '#get_feedback' do
    subject { crater.get_feedback(item_id, response_id, response_text) }

    context 'C-Rater service works as expected' do
      before do
        stub_request(:post, "#{protocol}#{url}/")
          .with(
            body: xml_req_spec,
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Basic Y2M6cGFzc3dvcmQ=',  # Base64 encoding of "cc:password"
              'Content-Type' => 'text/xml; charset=ISO-8859-1',
              'User-Agent' => 'Ruby',
              'X-Api-Key' => 'fakekey'
            }
          ).to_return(status: 200, body: xml_resp_spec, headers: { 'Content-Type' => 'text/xml; charset=ISO-8859-1' })
      end

      it "returns score and additional information" do
        expect(subject[:success]).to be true
        expect(subject[:score]).to eql(score)
        expect(subject[:error]).to be_nil
        expect(subject[:response_info][:code]).to eql(200)
        expect(subject[:response_info][:body]).to eql(xml_resp_spec)
        expect(subject[:response_info][:headers]).not_to be_nil
      end
    end

    context 'C-Rater service returns error' do
      before do
        stub_request(:post, "#{protocol}#{url}")
          .with(
            body: xml_req_spec,
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Basic Y2M6cGFzc3dvcmQ=',  # Base64 encoding of "cc:password"
              'Content-Type' => 'text/xml; charset=ISO-8859-1',
              'User-Agent' => 'Ruby',
              'X-Api-Key' => 'fakekey'
            }
          ).to_return(status: status_code, body: err_body, headers: headers)
      end

      context 'quota exceeded error' do
        let(:status_code) { 429 }
        let(:err_body) { 'Sorry, automated scoring is not available at this time.' }
        let(:headers) { {'Content-Type' => 'text/plain; charset=ISO-8859-1'} }

        it 'returns only debug information' do
          expect(subject[:success]).to be false
          expect(subject[:score]).to be_nil
          expect(subject[:error]).to eql(err_body)
          expect(subject[:response_info][:code]).to eql(status_code)
          expect(subject[:response_info][:body]).to eql(err_body)
          expect(subject[:response_info][:headers]).not_to be_nil
        end
      end

      context 'unknown error' do
        let(:status_code) { 404 }
        let(:err_body) { 'Page not found' }
        let(:headers) { {'Content-Type' => 'text/plain; charset=ISO-8859-1'} }

        it 'returns only debug information' do
          expect(subject[:success]).to be false
          expect(subject[:score]).to be_nil
          expect(subject[:error]).to eql(err_body)
          expect(subject[:response_info][:code]).to eql(status_code)
          expect(subject[:response_info][:body]).to eql(err_body)
          expect(subject[:response_info][:headers]).not_to be_nil
        end
      end

      context 'meaningful error' do
        let(:status_code) { 200 }
        let(:err_code) { 102 }
        let(:err_msg) { 'No model found for the item. [Mon Feb 02 07:49:21 EST 2015]' }
        let(:headers) { {'Content-Type' => 'text/xml; charset=ISO-8859-1'} }
        let(:err_body) do
          xml = <<-EOS
            <crater-results>
              <tracking id="-1"/>
              <error code="#{err_code}">
                <![CDATA[#{err_msg}]]>
              </error>
              <client id="#{client_id}"/>
            </crater-results>
          EOS
          process_xml(xml)
        end

        it 'returns parsed error message' do
          expect(subject[:success]).to be false
          expect(subject[:score]).to be_nil
          expect(subject[:error]).to eql("Error #{err_code}: #{err_msg}")
          expect(subject[:response_info][:code]).to eql(status_code)
          expect(subject[:response_info][:body]).to eql(err_body)
          expect(subject[:response_info][:headers]).not_to be_nil
        end
      end
    end
  end

  describe "The Constructor params" do

    describe "The url param" do
      let(:crater) { CRater::APIWrapper.new(client_id, username, password, url, api_key) }
      let(:default_url) { CRater::APIWrapper::C_RATER_URI }

      describe "When blank" do
        # See: https://www.pivotaltracker.com/story/show/164411237
        let(:url) { "" }
        it "Will set @url to the default value" do
          expect(crater.instance_variable_get(:@url)).to eql(default_url)
        end
      end

      describe "When a nil" do
        let(:url) { nil }
        it "should use the default value of CRater::APIWrapper::C_RATER_URI" do
          expect(crater.instance_variable_get(:@url)).to eql(default_url)
        end
      end

      describe "When a valid URL" do
        let(:url) { "https://some.place.com" }
        it "should use the param url" do
          expect(crater.instance_variable_get(:@url)).to eql(url)
        end
      end
    end

    describe "The api_key param" do
      describe "when nil" do
        let(:api_key) { nil }
        it "will set @api_key to nil" do
          expect(crater.instance_variable_get(:@api_key)).to be_nil
        end

        it "will not set special api-key headers" do
          headers = crater.send(:request_headers)
          expect(headers.keys).not_to include('x-api-key')
        end
      end

      describe "when blank" do
        let(:api_key) { "" }
        it "will set @api_key to '' (blank)" do
          expect(crater.instance_variable_get(:@api_key)).to eql("")
        end

        it "will not set special api-key headers" do
          headers = crater.send(:request_headers)
          expect(headers.keys).not_to include('x-api-key')
        end
      end
    end
  end
end
