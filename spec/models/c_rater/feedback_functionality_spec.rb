require 'spec_helper'

describe CRater::FeedbackFunctionality do
  class CRaterFeedbackFunctionalityTestClass < ActiveRecord::Base
    # Well, it's not pretty, but I don't have idea how to solve that better. The goal is to test FeedbackFunctionality
    # isolated from the class that includes it.
    self.table_name = :embeddable_open_response_answers
    include CRater::FeedbackFunctionality
    attr_accessible :answer_text
  end

  let(:answer) do
    ans = CRaterFeedbackFunctionalityTestClass.create({
      answer_text: ans_text
    })
    # Stub interface required by feedback functionality:
    allow(ans).to receive(:c_rater_item_settings).and_return(item_settings)
    allow(ans).to receive(:question).and_return(question)
    ans
  end

  # In fact the question will delegate this...
  let(:question) { double({max_score: max_score})}
  let(:ans_text) { 'foobar' }
  let(:item_id) { 123 }
  let(:mapping_value) { 'barfoo mapping val' }
  let(:max_score) { 2 }
  let(:score_mapping) { CRater::ScoreMapping.create(mapping: {'score1' => '1', 'score2' => mapping_value}) }
  let(:item_settings) do
    s = CRater::ItemSettings.new(item_id: item_id)
    s.score_mapping = score_mapping
    s.save
    s
  end

  describe 'instance of class that includes feedback functionality' do
    subject { answer }

    it { is_expected.to respond_to(:c_rater_enabled?) }
    it { is_expected.to respond_to(:c_rater_config) }
    it { is_expected.to respond_to(:save_feedback) }
    it { is_expected.to respond_to(:max_score) }
    it 'should have access to C-Rater settings' do
      expect(answer.c_rater_item_settings).to be_a(CRater::ItemSettings)
    end

    it 'should have the max score we expect' do
      expect(answer.max_score).to eql max_score
    end

    context 'C-Rater not configured' do
      before(:each) do
        allow(answer).to receive(:c_rater_config).and_return(client_id: nil,
                                                             username: nil,
                                                             password: nil,
                                                             api_key: nil)
      end
      describe '#c_rater_enabled?' do
        subject { answer.c_rater_enabled? }
        it { is_expected.to be false }
      end
      describe '#save_feedback' do
        it 'should create feedback item with error message' do
          # WebMock raises an error if any web request is issued.
          answer.save
          answer.save_feedback
          # FeedbackItem with error message should be created.
          expect(answer.feedback_items.last.status).to eql(CRater::FeedbackItem::STATUS_ERROR)
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
      let(:api_key) { 'fakekey' }
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
                                                             api_key: api_key,
                                                             url: "#{protocol}#{url}")

        stub_request(:post, "#{protocol}#{url}").
         with(
           headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Basic Y29uY29yZDpwYXNzd29yZA==', # Base64 encoding of "concord:password"
            'Content-Type'=>'text/xml; charset=ISO-8859-1',
            'User-Agent'=>'Ruby',
            'X-Api-Key'=>'fakekey'
           }).
         to_return(status: 200, body: response, headers: {'Content-Type'=>'application/xml; charset=iso-8859-1'})
      end


      describe '#c_rater_enabled?' do
        subject { answer.c_rater_enabled? }
        it { is_expected.to be true }

        # API Key is an optional parameter used for new C-Rater service only
        describe 'when api_key is nil' do
          let(:api_key) { nil }
          it { is_expected.to be true }
        end

        # API Key is an optional parameter used for new C-Rater service only
        describe 'when api_key is blank' do
          let(:api_key) {''}
          it { is_expected.to be true }
        end

        # API Key is an optional parameter used for new C-Rater service only
        describe 'when api_key is present' do
          let(:api_key) {'something'}
          it { is_expected.to be true }
        end

      end

      describe '#save_feedback' do
        it 'creates feedback entry in DB (success)' do
          expect(answer.feedback_items.count).to eql(0)
          feedback = answer.save_feedback
          expect(feedback.status).to eql('success')
          expect(feedback.score).to eql(score)
          expect(feedback.max_score).to eql(max_score)
          expect(feedback.feedback_text).to eql(mapping_value)
          expect(feedback.response_info[:body]).to eql(response)
          expect(answer.feedback_items.count).to eql(1)
        end

        it 'creates multiple feedback entries in DB when called multiple times' do
          answer.save_feedback
          answer.save_feedback
          answer.save_feedback
          expect(answer.feedback_items.count).to eql(3)
        end

        describe "when answer_text matches a previous summission" do
          before(:each) do
            answer.save_feedback # Creates a first feedback item
          end

          it "wont call the scoring service" do
            expect(answer).to_not receive(:request_feedback_from_service)
            answer.save_feedback # Save a duplicate feedback item
          end

          it "will create a copy of the item" do
            expect(answer).to receive(:copy_of_feedback)
            answer.save_feedback
          end

          it "will add a new feedback item" do
            expect(answer.feedback_items.count).to eql(1)
            answer.save_feedback
            expect(answer.feedback_items.count).to eql(2)
          end

          it "will have the same score as the previous item" do
            last_score = answer.feedback_items.last.score
            answer.save_feedback
            expect(answer.feedback_items.last.score).to eql(last_score)
          end

          it "will have the same feedback_text as the previous item" do
            feedback_text = answer.feedback_items.last.feedback_text
            answer.save_feedback
            expect(answer.feedback_items.last.feedback_text).to eql(feedback_text)
          end

          it "will have the same status as the previous item" do
            status = answer.feedback_items.last.status
            answer.save_feedback
            expect(answer.feedback_items.last.status).to eql(status)
          end

          it "will have the same answer_text as the previous item" do
            answer_text = answer.feedback_items.last.answer_text
            answer.save_feedback
            expect(answer.feedback_items.last.answer_text).to eql(answer_text)
          end

          # TODO: How important is it to copy response_info?
          it "will have the same response_info as the previous item" do
            response_info = answer.feedback_items.last.response_info
            answer.save_feedback
            expect(answer.feedback_items.last.response_info).to eql(response_info)
          end
        end

        describe "when answer_text doesn't match a previous sumbission" do
          before(:each) do
            answer.save_feedback
          end

          it "it will ask the service to score again" do
            answer.update_attribute(:answer_text, 'A NOVEL ANSWER')
            expect(answer).to_not receive(:copy_of_feedback)
            expect(answer).to receive(:request_feedback_from_service)
            answer.save_feedback
          end

        end
      end

      describe '#get_saved_feedback' do
        it 'returns nil when there are no feedback items available' do
          feedback = answer.get_saved_feedback
          expect(feedback).to be_nil
        end

        it 'returns the last feedback item' do
          feedback = answer.save_feedback
          expect(answer.get_saved_feedback).to eql(feedback)
        end
      end

      context 'C-Rater service unavailable' do
        let(:err_resp) { 'Service unavailable' }
        before(:each) do
          stub_request(:post, "#{protocol}#{url}")
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Basic Y29uY29yZDpwYXNzd29yZA==', # Base64 encoding of "concord:password"
                'Content-Type' => 'text/xml; charset=ISO-8859-1',
                'User-Agent' => 'Ruby',
                'X-Api-Key' => 'fakekey'
              }
            ).to_return(status: 500, body: err_resp)
        end

        describe '#save_feedback' do
          it 'creates feedback entry in DB (error)' do
            expect(answer.feedback_items.count).to eql(0)
            answer.save_feedback
            expect(answer.feedback_items.count).to eql(1)
            feedback = answer.feedback_items.last
            expect(feedback.status).to eql('error')
            expect(feedback.feedback_text).to eql(err_resp)
            expect(feedback.response_info[:body]).to eql(err_resp)
          end
        end
      end

      context 'C-Rater item settings missing' do
        before(:each) do
          allow(answer).to receive(:c_rater_item_settings).and_return(nil)
        end

        describe '#c_rater_enabled?' do
          subject { answer.c_rater_enabled? }
          it { is_expected.to be false }
        end

        describe '#save_feedack' do
          it 'should create feedback item with error message' do
            answer.save_feedback
            # FeedbackItem with error message should be created.
            expect(answer.feedback_items.last.status).to eql(CRater::FeedbackItem::STATUS_ERROR)
          end
        end
      end

      context 'C-Rater item settings incomplete' do
        before(:each) do
          item_settings.item_id = ''
        end

        describe '#c_rater_enabled?' do
          subject { answer.c_rater_enabled? }
          it { is_expected.to be false }
        end

        describe '#save_feedack' do
          it 'should create feedback item with error message' do
            answer.save_feedback
            # FeedbackItem with error message should be created.
            expect(answer.feedback_items.last.status).to eql(CRater::FeedbackItem::STATUS_ERROR)
          end
        end
      end
    end
  end
end
