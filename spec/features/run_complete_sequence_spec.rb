require 'spec_helper'
require 'uri'

feature "Visiting all pages of a Sequence" do
  let(:sequence)          { FactoryGirl.create(:sequence_with_activity, seq_options) }
  let(:params)            { {} }
  let(:activities_count)  { 2 }
  let(:name) { 'teacher-view mode test Sequence'}
  let(:seq_options) do
    {
      title: name,
      activities_count: activities_count
    }
  end

  let(:url) do
    sequence_path(sequence, params: params)
  end

  feature "not as a teacher" do

    scenario "We shouldn't see 'teacher-view' in the url" do
      expect(sequence.activities.length).to be(activities_count)
      visit url
      expect(page).to have_content name
      expect(current_url).to_not match 'teacher-view'
      expect(sequence.activities.length).to be(2)

      sequence.activities.each do |activity|
        expect(activity.pages.length).to be(2)
        expect(page).to have_content activity.name
      end
      # expect(sequence.activities.first.pages.length).to be(2)
      # expect(sequence.activities.last.pages.length).to be(2)
      activity = sequence.activities.first
      click_link(activity.name)
      click_link "begin_activity"

      # activity 1, page 1
      save_page("capy.html")
      expect(current_url).to_not match 'teacher-view'
      expect(find("//h4")).to have_content(activity.pages.first.name)
      find(:css, "a.next.forward_nav", match: :first).click

      # activity 1, page 2
      save_page("capy2.html")
      find(:css, "a.next.forward_nav", match: :first).click

      # activity 1, Summary Page, looks different
      save_page("capy-a1-ps.html")
      find(:css, ".next-page a.next.forward_nav", match: :first).click # next act link

       # activity 2, Intro Page
      activity = sequence.activities[1]
      expect(page).to have_content activity.name
      save_page("capy-a2-intro.html")
      click_link "begin_activity"

      # activity 2, Page 1
      save_page("capy-a2-p1.html")
      expect(current_url).to_not match 'teacher-view'
      expect(find("//h4")).to have_content(activity.pages.first.name)
      find(:css, "a.next.forward_nav", match: :first).click

    end
  end

  feature "as a teacher..." do
    let(:params) { {mode: 'teacher-view' } }
    scenario "We should see 'teacher-view' in the url" do
      expect(sequence.activities.length).to be(activities_count)
      visit url
      expect(page).to have_content name
      expect(current_url).to match 'teacher-view'
      expect(sequence.activities.length).to be(2)

      sequence.activities.each do |activity|
        expect(activity.pages.length).to be(2)
        expect(page).to have_content activity.name
      end
      # expect(sequence.activities.first.pages.length).to be(2)
      # expect(sequence.activities.last.pages.length).to be(2)
      activity = sequence.activities.first

      # Sequence page
      click_link(activity.name)
      expect(current_url).to match 'teacher-view'

      # Activity 1 Intro page
      click_link "begin_activity"
      expect(current_url).to match 'teacher-view'

      # activity 1, page 1
      expect(current_url).to match 'teacher-view'
      expect(find("//h4")).to have_content(activity.pages.first.name)
      find(:css, "a.next.forward_nav", match: :first).click

      # activity 1, page 2
      find(:css, "a.next.forward_nav", match: :first).click

      # activity 1, Summary Page, looks different
      expect(current_url).to match 'teacher-view'
      find(:css, ".next-page a.next.forward_nav", match: :first).click # next act link

       # activity 2, Intro Page
      activity = sequence.activities[1]
      expect(current_url).to match 'teacher-view'
      expect(page).to have_content activity.name
      click_link "begin_activity"

      # activity 2, Page 1
      expect(current_url).to match 'teacher-view'
      expect(find("//h4")).to have_content(activity.pages.first.name)
      find(:css, "a.next.forward_nav", match: :first).click

    end
  end

end
