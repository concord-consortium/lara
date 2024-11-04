require 'spec_helper'
require 'uri'

feature "Author edits a sequence while it is being used" do
  # If we change to using plugins for banners, we will need to remove
  # any assertions that use the teacher edition regex pattern....
  let(:teacher_edition_regex)  { /teacher edition/i }

  let(:author)       { FactoryGirl.create(:author) }
  let(:user)         { FactoryGirl.create(:user) }
  let(:page1)        { FactoryGirl.create(:page) }
  let(:page2)        { FactoryGirl.create(:page) }
  let(:page3)        { FactoryGirl.create(:page) }
  let(:page4)        { FactoryGirl.create(:page) }
  let(:page5)        { FactoryGirl.create(:page) }
  let(:page6)        { FactoryGirl.create(:page) }
  let(:activity1)    { FactoryGirl.create(:activity, pages: [page1, page2]) }
  let(:activity2)    { FactoryGirl.create(:activity, pages: [page3, page4]) }
  let(:activity3)    { FactoryGirl.create(:activity, pages: [page5, page6]) }
  let(:sequence)     { FactoryGirl.create(:sequence, title: 'teacher-edition mode test Sequence', user_id: author.id, lightweight_activities: [activity1, activity2], publication_status: 'public')}
  # Note that platform_id is a "platform_info" that we care about. externalId and returnUrl are necessary for
  # sequence run lookup.
  let(:portal_params) { "?platform_id=test_platform&externalId=123&returnUrl=http://return.url" }

  def current_sequence_run
    # find the SequenceRun from the current url
    sequence_run_key = current_url.match(/\/([^\/]*)$/)[1]
    SequenceRun.find_by_key(sequence_run_key)
  end

  def execute_test_for_reload_url
    # Ensure that a new activity run is created and platform info is passed down to the new run.
    login_as user, scope: :user

    expect(SequenceRun.count).to eq 0
    visit sequence_path(sequence) + portal_params
    expect(SequenceRun.count).to eq 1

    first_sequence_run = current_sequence_run
    expect(first_sequence_run.platform_id).to eq "test_platform"
    expect(first_sequence_run.runs.count).to eq 2
    expect(first_sequence_run.runs[0].platform_id).to eq "test_platform"
    expect(first_sequence_run.runs[1].platform_id).to eq "test_platform"

    sequence.lightweight_activities << activity3

    expect(first_sequence_run.runs.count).to be 2

    visit yield

    expect(SequenceRun.count).to eq 1

    # make sure the revisiting the url doesn't cause some kind of strange re-creation of
    # the sequence run key
    expect(current_sequence_run).to eq(first_sequence_run)

    # might need to reload this object here
    first_sequence_run.reload
    expect(first_sequence_run.runs.count).to eq 3
    expect(first_sequence_run.runs[0].platform_id).to eq "test_platform"
    expect(first_sequence_run.runs[1].platform_id).to eq "test_platform"
    expect(first_sequence_run.runs[2].platform_id).to eq "test_platform"
  end

  scenario "student runs sequence, then author adds a new activity, student reloads sequence" do
    execute_test_for_reload_url { current_url }
  end

  scenario "student runs sequence from Portal, then author adds a new activity, student starts sequence from Portal again" do
    execute_test_for_reload_url { sequence_path(sequence) + portal_params }
  end
end
