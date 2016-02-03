require 'spec_helper'

describe DashboardRunlist do
  include_context "activity with arg block submissions"
  let(:runlist) { DashboardRunlist.new([@run.remote_endpoint], page.id).to_hash }

  it 'returns all the submissions of provided runs' do
    expect(runlist.length).to eql(1)
    expect(runlist[0][:endpoint_url]).to eql(@run.remote_endpoint)
    expect(runlist[0][:last_page_id]).to eql(page.id)
    expect(runlist[0][:submissions].length).to eql(1)
    expect(runlist[0][:submissions][0][:answers].length).to eql(4)
    expect(runlist[0][:submissions][0][:answers][0][:answer]).to eql('text1')
    expect(runlist[0][:submissions][0][:answers][0][:score]).to eql(1)
    expect(runlist[0][:submissions][0][:answers][1][:answer]).to eql('text2')
    expect(runlist[0][:submissions][0][:answers][1][:score]).to eql(2)
    expect(runlist[0][:submissions][0][:answers][2][:answer]).to eql('text3')
    expect(runlist[0][:submissions][0][:answers][2][:score]).to eql(3)
    expect(runlist[0][:submissions][0][:answers][3][:answer]).to eql('text4')
    expect(runlist[0][:submissions][0][:answers][3][:score]).to eql(4)
  end

  it 'includes a reference to the sequence' do
    expect(runlist[0][:sequence_id]).to eql (sequence_id)
  end

  describe "when the run doesn't belong to a sequence" do
    let(:sequence_id) { nil }
    it "should include a nil reference for a sequence" do
      expect(runlist[0][:sequence_id]).to be_nil
    end
  end
end