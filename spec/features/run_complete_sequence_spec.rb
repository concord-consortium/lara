# NOTE: this spec is disabled because runs are no longer created when viewing activities, instead the user is redirected to the Activity Player.

# require 'spec_helper'
# require 'uri'

# feature "Visiting all pages of a Sequence" do
#   # If we change to using plugins for banners, we will need to remove
#   # any assertions that use the teacher edition regex pattern....
#   let(:teacher_edition_regex)  { /teacher edition/i }

#   let(:user)         { FactoryBot.create(:user) }
#   let(:page1)        { FactoryBot.create(:page) }
#   let(:page2)        { FactoryBot.create(:page) }
#   let(:page3)        { FactoryBot.create(:page) }
#   let(:page4)        { FactoryBot.create(:page) }
#   let(:activity1)    { FactoryBot.create(:activity, pages: [page1, page2]) }
#   let(:activity2)    { FactoryBot.create(:activity, pages: [page3, page4]) }
#   let(:sequence)     { FactoryBot.create(:sequence, :title => 'teacher-edition mode test Sequence', :user_id => user.id, :lightweight_activities => [activity1, activity2], :publication_status => 'public')}
#   let(:sequence_run) { FactoryBot.create(:sequence_run, :sequence_id => sequence.id, :user_id => user.id, remote_id: nil, remote_endpoint: nil) }
#   let(:run1)         { FactoryBot.create(:run, :activity_id => activity1.id, :user_id => user.id, :sequence => sequence, :sequence_run => sequence_run) }
#   let(:run2)         { FactoryBot.create(:run, :activity_id => activity2.id, :user_id => user.id, :sequence => sequence, :sequence_run => sequence_run) }
#   let(:params)       { {} }

#   let(:sequence_url) do
#     sequence_path(sequence, params: params)
#   end

#   before(:each) do
#     # reference the runs so they are created
#     run1
#     run2
#     login_as user, :scope => :user
#   end

#   def navigate(selector)
#     case selector
#     when :page
#       find(:css, "a.next.forward_nav", match: :first).click
#     when :activity
#       find(:css, ".next-page a.next.forward_nav", match: :first).click
#     end
#   end

#   def verify_param_assertions(assertions)
#     present = assertions[:present] || []
#     absent = assertions[:absent] || []
#     present.each do  |param, value|
#       expect(current_url).to match "#{param}=#{value}"
#     end
#     absent.each do |param, _value|
#       expect(current_url).to_not match "#{param}"
#     end
#   end

#   def navigate_and_verify(selector, presence)
#     navigate selector
#     verify_param_assertions presence
#   end

#   def verify_param_passed_through_sequence(param_assertions)
#     # Sequence page, which is an index of activities:
#     visit sequence_url

#     # Pre-test our test-case is what we expect.
#     expect(sequence.activities.length).to be(2)
#     # In our first url verify the current URL `present` params only.
#     verify_param_assertions(present: param_assertions[:present])

#     activity = sequence.activities.first
#     puts "!!!!!!!!!!ACTIVITY!!!!!!"
#     puts activity.as_json
#     click_link(activity.name)

#     # activity 1, Intro Page
#     click_link "begin_activity"
#     verify_param_assertions(param_assertions)

#     expect(find("//h4")).to have_content(activity.pages.first.name)

#     activity.pages.each do
#       navigate_and_verify :page, param_assertions
#     end

#     # activity 1, Summary Page, looks different
#     navigate_and_verify :activity, param_assertions
#     expect(page).to have_content sequence.activities[1].name

#     # activity 2, Intro Page
#     click_link "begin_activity"
#     verify_param_assertions(param_assertions)
#     expect(find("//h4")).to have_content(sequence.activities[1].pages.first.name)

#     sequence.activities[1].pages.each do
#       navigate_and_verify :page, param_assertions
#     end

#   end

#   feature "'mode' query parameter handling" do

#     feature "not as a teacher..." do
#       scenario "We should NOT see 'teacher-edition' in the url" do
#         verify_param_passed_through_sequence(absent: {mode:'teacher-edition'})
#       end
#     end

#     feature "as a teacher " do
#       feature "with `mode` set to `teacher-edition` " do
#         let(:params) { {mode: 'teacher-edition' } }
#         scenario "We should see 'mode=teacher-edition' in the url" do
#           verify_param_passed_through_sequence(present: {mode:'teacher-edition'})
#         end

#         scenario "We should see the Teacher View banner on the first page" do
#           visit sequence_url
#           expect(page.body).to match(teacher_edition_regex)
#         end

#         feature "When we are redirected to page 2 of activity 1 by our run" do
#           let(:activity) { sequence.activities.first }
#           let(:run_page) { activity.pages[1] }
#           let(:activity_url) do
#             # set the last active page
#             run1.page = run_page
#             run1.save!
#             sequence_activity_path(sequence, activity, params: params)
#           end

#           scenario "The redirected page retain our mode param" do
#             visit activity_url
#             # We assume that we have been redirected to
#             # /sequence/:id/activity/:id/page/:id
#             expected_url = "https://activity-player.concord.org/branch/master?sequence=http%3A%2F%2Fwww.example.com%2Fapi%2Fv1%2Fsequences%2F#{sequence.id}.json&sequenceActivity=activity_#{activity.id}"
#             # expected_url = "/sequences/#{sequence.id}/activities/#{activity.id}/pages/#{run_page.id}"
#             expect(current_url).to match(expected_url)
#             teacher_mode = "mode=teacher-edition"
#             expect(current_url).to match(teacher_mode)
#             expect(page.body).to match(teacher_edition_regex)
#           end

#           scenario "We click on the Sequence title and retain our mode param" do
#             visit activity_url
#             selector = "#container > header > div > div.site-logo.logo-l > div > h2 > a"
#             find(:css, selector, match: :first).click
#             teacher_mode = "mode=teacher-edition"
#             expect(current_url).to match(teacher_mode)
#             expect(page.body).to match(teacher_edition_regex)
#           end
#         end

#         scenario "We should see the Teacher View banner on the last page" do
#           verify_param_passed_through_sequence(present: {mode:'teacher-edition'})
#           expect(page.body).to match(teacher_edition_regex)
#           expect(current_url).to match "mode=teacher-edition"
#         end
#       end

#       feature "Combined with non-pass-through param `foo=bar` " do
#         let(:params) { {mode: 'teacher-edition', foo: 'bar'} }
#         scenario "We should see 'mode=teacher-edition' in the url, and not foo=bar" do
#           verify_param_passed_through_sequence(
#             present: { mode:'teacher-edition' },
#             absent:  { foo:'bar' }
#           )
#         end
#       end

#     end
#   end
# end

