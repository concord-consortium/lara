require 'spec_helper'

describe Api::V1::QuestionTrackersController do
  let(:activity) { FactoryGirl.create(:activity) }
  let(:run) {
    r = FactoryGirl.create(:run, remote_endpoint: endpoint_url)
    r.activity = activity
    r.save
    r
  }

  let(:master_question)  { FactoryGirl.create(:open_response, prompt:prompt1) }
  let(:question_tracker) { QuestionTracker.create(master_question:master_question, name:'my_first_question_tracker') }
  let(:page1)            { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
  let(:prompt1)          { "xyzzy" }
  let(:open_response1)   { FactoryGirl.create(:open_response, prompt:prompt1) }
  let(:answer_text)      { "I answered it" }
  let(:endpoint_url)    { "http://fake.blarg.com/blarg/1" }

  def get_answer(_run, _question)
    return Embeddable::AnswerFinder.new(_run).find_answer(_question)
  end

  # these API tests might be improved by using a json matcher such as:
  # https://github.com/waterlink/rspec-json_expectations/

  # it seems this should all be moved into some kind of factory or helper
  # since it is duplicated with the reporter_spec
  before(:each) {
    page1.add_embeddable(open_response1)
    activity.pages << page1

    question_tracker.add_question(open_response1)

    # prevent the portal sender from trying to send answers to the portal
    allow_any_instance_of(PortalSender::Protocol).to receive(:post_answers).and_return(true)

    a = get_answer(run, open_response1)
    a.update_attribute(:answer_text, answer_text)
  }

  it "exists" do
    expect(activity).to_not be_nil
  end

  describe 'find_by_activity' do
    it "should return the question tracker" do
      get :find_by_activity, params: { activity_id: activity.id }
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]).to include('id' => question_tracker.id,
                                          'name' => question_tracker.name)
    end

    it "should return a question tracker with the correct report_url" do
      get :find_by_activity, params: { activity_id: activity.id }
      tracker_info = JSON.parse(response.body)[0]
      # This worked before(?!) Used to check if the URL include #activity_id (instead of tracker_id), which is wrong.
      expect(tracker_info['report_url']).to match(/\/\/test.host\/api\/v1\/question_trackers\/\d+\/report/)
    end
  end

  describe 'report' do
    # need to pass a tracker id and array of run endpoints
    it "should return the question tracker and answers" do
      get :report, params: { question_tracker_id: question_tracker.id, endpoints: [endpoint_url] }
      expect(response.body).to include('question_tracker', 'answers')
    end
    it "should return the answer" do
      get :report, params: { question_tracker_id: question_tracker.id, endpoints: [endpoint_url] }
      json_response = JSON.parse(response.body)
      expect(json_response['answers'][0]['answer_hash']['answer']).to eq(answer_text)
    end
  end
end
