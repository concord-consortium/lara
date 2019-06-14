require 'spec_helper'

describe ReportService::RunSender do
  let(:host)      { "app.lara.docker" }
  let(:key)       { "run-key "}

  let(:user)      { double("User", {email: "anon@concord.org", id: 34}) }

  let(:created_at)      { Time.new(2016) }
  let(:updated_at)      { created_at + 0.5}
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
  let(:class_hash)           { "15291405-6B03-4E50-B49F-ACBC99D6255F" }
  let(:platform_id)          { "test.portal.com" }
  let(:platform_user_id)     { 123 }
  let(:resource_link_id)     { 321 }
  let(:answers) do
    1.upto(5).map do |index|
      url = "#{host}activities/#{index}"
      report_service_hash = { question_id: index, type: "mock-answer", url: url }
      double("Answer", {
        report_service_hash: report_service_hash,
        created_at: created_at,
        updated_at: updated_at
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
      platform_id: platform_id,
      platform_user_id: platform_user_id,
      context_id: class_hash,
      resource_link_id: resource_link_id,
      answers: answers
    })
  end
  let(:sender) { ReportService::RunSender.new(run, host)     }

  before(:each) do
    allow(Rails.application.routes.url_helpers).to receive(:run_path).and_return("runs/12345")
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
          "version", "created", "user_email",
          "answers", "context_id", "run_key"
        )
      end

      describe "the encoded answers" do
        it "should also include metadata" do
          answers = json["answers"]
          expect(answers.length).to be 5
          answers.each_with_index do |a|
            expect(a["tool_id"]).to match("app_lara_docker")
            expect(a["tool_id"]).not_to match("/")
            expect(a["tool_id"]).not_to match(/\./)
            expect(a["resource_url"]).to match("#{host}/sequences/#{sequence_id}")
            expect(a).to include("created")
            expect(a).to include("url")
            expect(a).to include("run_key")
            expect(a).to include("user_email")
            expect(a).to include("context_id" => class_hash)
            expect(a).to include("class_info_url" => class_info_url)
            expect(a).to include("version")
          end
        end

        describe "with one answer that hasn't changed" do
          let(:report_service_hash) do
            { question_id: "fake_answer_1", type: "mock-answer", url: "url" }
          end
          let(:unchanged_answer) do
            double("Answer", {
              report_service_hash: report_service_hash,
              created_at: created_at,
              updated_at: created_at # Not changed since created
            })
          end
          it "The answers json should not include the unchanged answer" do
            answers << unchanged_answer
            expect(answers.length).to be  6
            expect(json["answers"].length).to be 5
          end
        end

        # Ensure that broken answers won't kill the run_sender
        describe "With broken or non-conforming answers" do
          let(:boom) { "boom" }
          let(:exploding_answer) do
            answer = double("Answer", {
              created_at: created_at,
              updated_at: updated_at
            })
            allow(answer).to receive(:report_service_hash).and_raise(boom)
            answer
          end
          it "The JSON should include the good answers, and log bad ones" do
            expect(Rails.logger).to receive(:error).with(/#{boom}/)
            answers << exploding_answer
            accepted_answers = json["answers"]
            # bad answers wont appear in the JSON
            expect(answers.length).to be > accepted_answers.length
          end
        end

        describe "when run is part of the sequence" do
          it "the resource_url should be sequence url" do
            expect(json["resource_url"]).to match("#{host}/sequences/#{sequence_id}")
          end
        end

        describe "when run isn't part of the sequence" do
          let(:sequence_id) { nil }
          it "the resource_url should be activity url" do
            expect(json["resource_url"]).to match("#{host}/activities/#{sequence_id}")
          end
        end

      end
    end
  end

end
