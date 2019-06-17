require 'spec_helper'


describe SubmitDirtyAnswersJob do

  let(:answers) do
    5.times.map { |i| double("Asnwer", {}) }
  end

  let(:run_stubs) do
    {
      key: "run-key",
      dirty_answers: answers,
      id: run_id,
      send_to_portal: true,
      set_answers_clean: true,
      reload: true,
      abort_job_and_requeue: true
    }
  end

  let(:run_id) { 7 }

  let(:run) { double("Run", run_stubs) }
  let(:report_service_configured) { false}
  let(:submit_time) { Time.now }
  let(:job) { SubmitDirtyAnswersJob.new(run_id, submit_time) }

  before(:each) do
    allow(ReportService)
      .to receive(:configured?)
      .and_return report_service_configured

    allow(Run).to receive(:find).with(run_id).and_return(run)
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
      let(:report_service_configured) { true }
      it "should send data to the report service" do
        expect(job).to receive(:send_to_report_service).with(run)
        expect { job.perform }.not_to raise_error
      end
      describe "When something goes wrong while sending" do
        before(:each) do
          allow_any_instance_of(ReportService::RunSender)
            .to receive(:send)
            .and_raise("bang")
        end
        it "should report an error without halting" do
          expect(Rails.logger).to receive(:error).at_least(:once)
          expect { job.perform }.not_to raise_error
        end
      end
    end
  end
end
