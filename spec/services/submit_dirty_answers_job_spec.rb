require 'spec_helper'

describe SubmitDirtyAnswersJob do
  let(:self_host) { "app.lara.docker" }
  let(:report_service_url) { 'http://fake-report-service.fake' }
  let(:report_service_token) { 'very-secret-token' }
  let(:run) do
    FactoryBot.create(:run, { open_response_answers: [ FactoryBot.create(:or_answer) ], is_dirty: true })
  end
  let(:submit_time) { Time.now }
  let(:report_service_configured) { true}
  let(:report_service_response) do
    {
      success?: true,
      code: 200,
      message: "OK",
      body: "{ success: true }"
    }
  end

  let(:job) { SubmitDirtyAnswersJob.new(run.id, submit_time) }

  before(:each) do
    allow(ReportService)
      .to receive(:configured?)
      .and_return report_service_configured

    allow(HTTParty)
      .to receive(:post)
      .and_return double("Response", report_service_response)

    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return(self_host)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return(report_service_url)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return(report_service_token)
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return(nil)
  end

  describe "#perform" do
    it "mark run clean after successful upload to Portal and report service" do
      expect(run.dirty_answers.count).to eq(1)
      expect { job.perform }.not_to raise_error
      run.reload
      expect(run.dirty_answers.count).to eq(0)
      expect(run.is_dirty).to eq(false)
    end
  end

  describe "#send_to_report_service" do
    describe "when the report service is not configured" do
      let(:report_service_configured) { false }
      it "we shouldn't send data to the report service" do
        expect(job).not_to receive(:send_to_report_service)
        expect { job.perform }.not_to raise_error
      end
    end

    describe "When the report service is configured" do
      it "should send data to the report service" do
        expect(job).to receive(:send_to_report_service).with(run)
        expect { job.perform }.not_to raise_error
      end

      describe "When something goes wrong while sending (exception)" do
        before(:each) do
          allow_any_instance_of(ReportService::RunSender)
            .to receive(:send)
            .and_raise("bang")
        end
        it "shouldn't catch this exception to re-run job" do
          expect { job.perform }.to raise_error("bang")
        end
      end

      describe "When something goes wrong while sending (report service response)" do
        let(:report_service_response) do
          {
            success?: false,
            code: 500,
            message: "ERROR",
            body: "{ success: false }"
          }
        end

        it "should raise error to re-run job" do
          expect { job.perform }.to raise_error(Run::PortalUpdateIncomplete)
        end
      end
    end
  end
end
