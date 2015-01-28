require 'spec_helper'

describe CRater do
  let(:client_id)     { 'concord' }
  let(:username)      { 'cc' }
  let(:password)      { 'password' }
  let(:protocol)      { 'https://'}
  let(:url)           { 'c-rater.fake.url.org' }
  let(:item_id)       { 'fake_item_id' }
  let(:response_id)   { 123 }
  let(:response_text) { 'response abc xyz' }
  let(:score)         { 2 }
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

  let(:crater) { CRater.new(client_id, username, password, "#{protocol}#{url}") }

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

    describe 'when C-Rater service works as expected' do
      before do
        stub_request(:post, "#{protocol}#{username}:#{password}@#{url}").
          with(:body => xml_req_spec,
               :headers => {'Content-Type'=>'application/xml; charset=iso-8859-1'}).
          to_return(:status => 200, :body => xml_resp_spec,
                    :headers => {'Content-Type'=>'application/xml; charset=iso-8859-1'})
      end

      it "returns score and additional information" do
        expect(subject[:success]).to be true
        expect(subject[:score]).to eql(score)
        expect(subject[:code]).to eql(200)
        expect(subject[:body]).to eql(xml_resp_spec)
        expect(subject[:headers]).not_to be_nil
      end
    end

    describe 'when C-Rater service is unavailable' do
      before do
        stub_request(:post, "#{protocol}#{username}:#{password}@#{url}").
          with(:body => xml_req_spec,
               :headers => {'Content-Type'=>'application/xml; charset=iso-8859-1'}).
          to_return(:status => 404, :body => 'Page not found')
      end

      it "returns only debug information" do
        expect(subject[:success]).to be false
        expect(subject[:score]).to be_nil
        expect(subject[:code]).to eql(404)
        expect(subject[:body]).to eql('Page not found')
        expect(subject[:headers]).not_to be_nil
      end
    end
  end
end
