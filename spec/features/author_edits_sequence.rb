require 'spec_helper'
require 'uri'

feature "Author edits a sequence while it is being used" do
  # If we change to using plugins for banners, we will need to remove
  # any assertions that use the teacher edition regex pattern....
  let(:teacher_edition_regex)  { /teacher edition/i }

  let(:author)         { FactoryGirl.create(:author) }
  let(:page1)        { FactoryGirl.create(:page) }
  let(:page2)        { FactoryGirl.create(:page) }
  let(:page3)        { FactoryGirl.create(:page) }
  let(:page4)        { FactoryGirl.create(:page) }
  let(:page5)        { FactoryGirl.create(:page) }
  let(:page6)        { FactoryGirl.create(:page) }
  let(:activity1)    { FactoryGirl.create(:activity, pages: [page1, page2]) }
  let(:activity2)    { FactoryGirl.create(:activity, pages: [page3, page4]) }
  let(:activity3)    { FactoryGirl.create(:activity, pages: [page5, page6]) }
  let(:sequence)     { FactoryGirl.create(:sequence, :title => 'teacher-edition mode test Sequence', :user_id => author.id, :lightweight_activities => [activity1, activity2], :publication_status => 'public')}

  def current_sequence_run
    # find the SequenceRun from the current url
    sequence_run_key = current_url.match(/\/([^\/]*)$/)[1]
    SequenceRun.find_by_key(sequence_run_key)
  end

  scenario "student runs sequence, then author adds a new activity, student continues running sequence" do
    visit sequence_path(sequence)

    # binding.pry
    first_sequence_run = current_sequence_run
    expect(first_sequence_run.runs.count).to be 2

    sequence.lightweight_activities << activity3

    expect(first_sequence_run.runs.count).to be 2

    visit current_url

    # make sure the revisiting the url doesn't cause some kind of strange re-creation of
    # the sequence run key
    expect(current_sequence_run).to eq(first_sequence_run)

    # might need to reload this object here
    first_sequence_run.reload
    expect(first_sequence_run.runs.count).to be 3
  end

  # TODO add an additional scenario to confirm that the platform params are correctly
  # copied to the new activity run when it is created when revisiting the page after
  # the activity was added.
  # it might be necessary to browse to an activity in the sequence first before adding
  # the new activity. I suspect the code which redirects to the current activity doesn't
  # trigger the setting of the platform info
end
