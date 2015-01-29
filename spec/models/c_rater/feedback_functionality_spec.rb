require 'spec_helper'

describe CRater::FeedbackFunctionality do
  class FeedbackFunctionalityTestClass < ActiveRecord::Base
    # Well, it's not pretty, but I don't have idea how to solve that better. The goal is to test FeedbackFunctionality
    # isolated from the class that includes it.
    self.table_name = :embeddable_open_response_answers
    include CRater::FeedbackFunctionality
  end

  let(:answer) do
    ans = FeedbackFunctionalityTestClass.create
    # Stub interface required by feedback functionality:
    allow(ans).to receive(:answer_text).and_return(ans_text)
    allow(ans).to receive(:c_rater_settings).and_return(settings)
    ans
  end

  let(:ans_text) { 'foobar' }
  let(:item_id) { 123 }
  let(:settings) { CRater::Settings.new(item_id: item_id) }

  describe 'instance of class that includes feedback functionality' do
    subject { answer }

    it { is_expected.to respond_to(:c_rater_enabled?) }
    it { is_expected.to respond_to(:c_rater_config) }
    it { is_expected.to respond_to(:get_c_rater_feedback) }

    it 'should have access to C-Rater settings' do
      expect(answer.c_rater_settings).to be_a(CRater::Settings)
    end

    context 'C-Rater not configured' do
      before(:each) do
        allow(answer).to receive(:c_rater_config).and_return(client_id: nil,
                                                             username: nil,
                                                             password: nil)
      end
      describe '#c_rater_enabled?' do
        subject { answer.c_rater_enabled? }
        it { is_expected.to be false }
      end
      describe '#get_c_rater_feedback' do
        it 'should do nothing' do
          # WebMock raises an error if any web request is issued.
          answer.save
          answer.get_c_rater_feedback
        end
      end
    end

    context 'C-Rater configured' do
      let(:client_id) { 'cc' }
      let(:username) { 'concord' }
      let(:password) { 'password' }
      let(:protocol) { 'https://' }
      let(:url) { 'fake.c-rater.api/api/v1' }
      let(:score) { 2 }
      let(:response) do
        <<-EOS
          <crater-results>
            <tracking id="12345"/>
            <client id="#{client_id}"/>
            <items>
              <item id="123">
                <responses>
                  <response id="#{answer.id}" score="#{score}" concepts="3,6" realNumberScore="2.62039"
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
      end
      before(:each) do
        allow(answer).to receive(:c_rater_config).and_return(client_id: client_id,
                                                             username: username,
                                                             password: password,
                                                             url: "#{protocol}#{url}")
        stub_request(:post, "#{protocol}#{username}:#{password}@#{url}").
          to_return(:status => 200, :body => response,
                    :headers => {'Content-Type'=>'application/xml; charset=iso-8859-1'})
      end

      describe '#c_rater_enabled?' do
        subject { answer.c_rater_enabled? }
        it { is_expected.to be true }
      end

      describe '#get_c_rater_feedback' do
        it 'creates feedback entry in DB' do
          expect(answer.c_rater_feedback_items.count).to eql(0)
          answer.get_c_rater_feedback
          expect(answer.c_rater_feedback_items.count).to eql(1)
          feedback = answer.c_rater_feedback_items.last
          expect(feedback.status).to eql('success')
          expect(feedback.score).to eql(score)
        end
      end
    end
  end
end
