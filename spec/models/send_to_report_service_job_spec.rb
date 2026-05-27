require 'spec_helper'

describe "SendToReportServiceJob" do
  before(:each) do
    allow(Sequence).to receive(:find).and_return(sequence)
    allow(ReportService::ResourceSender).to receive(:new).and_return(sender)
    allow(ReportService).to receive(:configured?).and_return(report_service_configured)
  end

  let(:report_service_configured) { true }
  let(:report_service_response) { { "status" => 200, "success" => true } }

  let(:payload_hash) { "FACF4D8E-7AD9-489C-8CEC-58D004500795" }
  let(:senderOpts) do
    {
      payload_hash: payload_hash,
      send: report_service_response
    }
  end

  let(:sender) { double("Sender", senderOpts) }

  let(:sequence_update_time) {  1.minute.ago }
  let(:last_report_service_hash) { "" }
  let(:sequence) do
    double("Sequence", {
      type: 'Sequence',
      id: 12,
      updated_at: sequence_update_time,
      last_report_service_hash: last_report_service_hash,
      update_column: true
    })
  end

  let(:queuetime) { Time.now }
  let(:job) do
    publishable_id = sequence.id
    publishable_type = sequence.type
    SendToReportServiceJob.new(publishable_type, publishable_id, queuetime)
  end

  it "the job should exist" do
    expect(job).not_to be_nil
  end

  describe "#perform" do

    describe "when the report service is not configured" do
      let(:report_service_configured) { false }
      it "should not raise an excpetion" do
        expect {  job.perform }.not_to raise_error
      end
      it "should not send a request to the report server" do
        expect(sender).not_to receive(:send)
        job.perform
      end
    end

    describe "when the published item has been modified afrer enqueuing" do
      let(:queuetime) { 1.hour.ago }
      it "the job should not throw an exception" do
        expect { job.perform }.not_to raise_error
      end
      it "the job should not make a requst to the report server" do
        expect(sender).not_to receive(:send)
        job.perform
      end
    end

    describe "when the published item has the same payload_hash" do
      let(:last_report_service_hash) { payload_hash }
      it "the job should not throw an exception" do
        expect { job.perform }.not_to raise_error
      end
      it "the job should not make a request to the report server" do
        expect(sender).not_to receive(:send)
        job.perform
      end
    end

    describe "when the server returns an error"  do
      let(:report_service_response) do
        double("HTTPartyResponse").tap do |r|
          allow(r).to receive(:[]).with("success").and_return(false)
          allow(r).to receive(:code).and_return(500)
          allow(r).to receive(:body).and_return('{"success":false,"error":{"details":"Property array contains an invalid nested entity."}}')
        end
      end

      it "the job should throw an exception to retry the job" do
        expect(sender).not_to receive(:update_column)
        expect { job.perform }.to raise_exception(SendToReportServiceJob::FailedToSendToReportService)
      end

      it "the exception message includes HTTP status and a body excerpt" do
        expect { job.perform }.to raise_exception(SendToReportServiceJob::FailedToSendToReportService) { |e|
          expect(e.message).to include("500")
          expect(e.message).to include("Property array contains an invalid nested entity")
        }
      end
    end

    describe "when everything goes just right" do
      it "should send the new structure to the report service" do
        expect(sender).to receive(:send)
        job.perform
      end
      it "should update the report_service_hash column" do
        expect(sequence).to receive(:update_column)
          .with(:last_report_service_hash, payload_hash)
        job.perform
      end
    end
  end
end