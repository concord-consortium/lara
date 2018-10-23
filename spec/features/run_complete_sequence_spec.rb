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

  let(:sequence_url) do
    sequence_path(sequence, params: params)
  end

  def navigate(selector)
    case selector
    when :page
      find(:css, "a.next.forward_nav", match: :first).click
    when :activity
      find(:css, ".next-page a.next.forward_nav", match: :first).click
    end
  end

  def verify_param_assertions(assertions)
    present = assertions[:present] || []
    absent = assertions[:absent] || []
    present.each do  |param, value|
      expect(current_url).to match "#{param}=#{value}"
    end
    absent.each do |param, _value|
      expect(current_url).to_not match "#{param}"
    end
  end

  def navigate_and_verify(selector, presence)
    navigate selector
    verify_param_assertions presence
  end

  def verify_param_passed_through_sequence(param_assertions)
    # Sequence page, which is an index of activities:
    visit sequence_url

    # Pre-test our test-case is what we expect.
    expect(sequence.activities.length).to be(2)
    # In our first url verify the current URL `present` params only.
    verify_param_assertions(present: param_assertions[:present])

    activity = sequence.activities.first
    click_link(activity.name)

    # activity 1, Intro Page
    click_link "begin_activity"
    verify_param_assertions(param_assertions)
    
    expect(find("//h4")).to have_content(activity.pages.first.name)

    activity.pages.each do
      navigate_and_verify :page, param_assertions
    end

    # activity 1, Summary Page, looks different
    navigate_and_verify :activity, param_assertions
    expect(page).to have_content sequence.activities[1].name

    # activity 2, Intro Page
    click_link "begin_activity"
    verify_param_assertions(param_assertions)
    expect(find("//h4")).to have_content(sequence.activities[1].pages.first.name)

    sequence.activities[1].pages.each do
      navigate_and_verify :page, param_assertions
    end

  end

  feature "'mode' query parameter handling" do

    feature "not as a teacher..." do
      scenario "We should NOT see 'teacher-view' in the url" do
        verify_param_passed_through_sequence(absent: {mode:'teacher-view'})
      end
    end

    feature "as a teacher " do
      feature "with `mode` set to `teacher-view` " do
        let(:params) { {mode: 'teacher-view' } }
        scenario "We should see 'mode=teacher-view' in the url" do
          verify_param_passed_through_sequence(present: {mode:'teacher-view'})
        end
        scenario "We should see the Teacher View banner on the page" do
          verify_param_passed_through_sequence(present: {mode:'teacher-view'})
          expect(page.body).to match("Teacher View")

        end
      end
      feature "Combined with non-pass-through param `foo=bar` " do
        let(:params) { {mode: 'teacher-view', foo: 'bar'} }
        scenario "We should see 'mode=teacher-view' in the url, and not foo=bar" do
          verify_param_passed_through_sequence(
            present: { mode:'teacher-view' },
            absent:  { foo:'bar' }
          )
        end
      end
    end
  end

  
end
