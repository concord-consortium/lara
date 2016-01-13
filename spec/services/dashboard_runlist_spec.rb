require 'spec_helper'

describe DashboardRunlist do
  include_context "activity with arg block submissions"

  it 'returns all the submissions of provided runs' do
    runlist = DashboardRunlist.new([@run.key], page.id).to_hash
    expect(runlist.length).to eql(1)
    expect(runlist[0][:key]).to eql(@run.key)
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