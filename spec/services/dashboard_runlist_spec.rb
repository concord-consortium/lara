require 'spec_helper'

describe DashboardRunlist do
  include_context "activity with arg block submissions"

  describe 'when run endpoint is secure (=> uses UUID key)' do
    before(:each) do
      @run.update_attributes(remote_endpoint: 'http://test.portal/dataservice/key:123-aaa-bbb-ccc-ddd-987-xyz')
    end

    it 'returns all the submissions of provided runs' do
      runlist = DashboardRunlist.new([@run.remote_endpoint], page.id).to_hash
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
  end

  describe 'when run endpoint is not secure (=> uses numeric ID)' do
    before(:each) do
      @run.update_attributes(remote_endpoint: 'http://test.portal/dataservice/123')
    end

    it 'does not return run data' do
      runlist = DashboardRunlist.new([@run.remote_endpoint], page.id).to_hash
      expect(runlist.length).to eql(0)
    end
  end
end