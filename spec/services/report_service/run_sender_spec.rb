require 'spec_helper'

describe ReportService::RunSender do
  let(:host)      { "app.lara.docker" }
  let(:key)       { "run-key "}

  let(:user)      { double("User", {email: "anon@concord.org", id: 34}) }

  let(:created_at)      { Time.new(2016) }
  let(:updated_at)      { created_at }
  let(:created)         { created_at }
  let(:run_count)       { 0 }
  let(:run_id)          { 1 }
  let(:activity_id)     { 2 }
  let(:sequence_id)     { 3 }
  let(:sequence_run_id) { 4 }
  let(:page_id)         { 5 }

  let(:collaboration_run_id) { nil }
  let(:remote_id)            { 'remote-id' }
  let(:remote_endpoint)      { "https://mock.data.com/spec/offering/1" }
  let(:class_info_url)       { "https://mock.data.com/spec/class/2" }
  let(:answers) do
    1.upto(5).map do |index|
      url = "#{host}activities/#{index}"
      portal_hash = {question_id: index, type: "mock-answer", url: url }
      double("Answer", {
        question_id: index,
        type: "mock_question",
        url: url,
        portal_hash: portal_hash,
        answer_id: 'mock_question_answer_10'
      })
    end
  end

  let(:run) do
    double("Run", {
      key: key,
      run_id: run_id,
      user: user,
      run_count: run_count,
      created_at: created_at,
      updated_at: updated_at,
      activity_id: activity_id,
      remote_id: remote_id,
      page_id: page_id,
      remote_endpoint: remote_endpoint,
      sequence_id: sequence_id,
      sequence_run_id: sequence_run_id,
      collaboration_run_id: collaboration_run_id,
      class_info_url: class_info_url,
      answers: answers
    })
  end
  let(:sender) { ReportService::RunSender.new(run, host)     }

  before(:each) do
    # allow(HTTParty).to receive(:post).and_return post_results
    Rails.application.routes.url_helpers.stub(:run_path).and_return("runs/12345")
    Timecop.freeze(Time.new(2016))
  end

  describe "to_json" do
    it "should be a string with a length" do
      expect(sender.to_json().length).to be > 1
    end
    it "should parse" do
      expect { JSON.parse(sender.to_json()) }.not_to raise_error
    end

    describe "the encoded values" do
      let(:json) { JSON.parse(sender.to_json())}
      it "should have a key fields" do
        expect(json).to include(
          "version", "created", "user_id",
          "answers", "class_hash", "key"
        )
      end

      describe "the encoded answers" do
        it "should also include the run_key, user_id, class_hash " do
          answers = json["answers"]
          answers.each do |a,index|
            expect(a).to include("key")
            expect(a["key"]).to match("app_lara_docker")
            expect(a["key"]).to match("mock-answer")
            expect(a["key"]).to match("#{index}")
            expect(a["key"]).to match(/\d+/)
            expect(a["key"]).not_to match("/")
            expect(a["key"]).not_to match(/\./)
            expect(a).to include("url")
            expect(a).to include("run_key")
            expect(a).to include("user_id")
            expect(a).to include("class_hash")
            expect(a).to include("created")
            expect(a).to include("version")
          end
        end
      end
    end

    end


    describe "send" do
      describe "version 1 of the sending protocol" do
      end
    end


end
