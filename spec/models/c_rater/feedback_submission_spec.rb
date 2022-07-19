# These tests are broken because of changes related to the new sections schema. It may be 
# that these tests are no longer needed. In the very least, they will need to be 
# adjusted in light of the new sections changes.
#
# require 'spec_helper'

# describe CRater::FeedbackSubmission do
#   before(:each) do
#     @users = FactoryGirl.create_list(:user, 2)
#     @activity = FactoryGirl.create(:activity_with_page)
#     @question = FactoryGirl.create(:multiple_choice)
#     @runs = FactoryGirl.create_list(:run, 2).each_with_index do |run, idx|
#       run.activity = @activity
#       run.user = @users[idx]
#       run.save!
#     end
#     @answers = FactoryGirl.create_list(:multiple_choice_answer, 2).each_with_index do |ans, idx|
#       ans.answers << FactoryGirl.create(:multiple_choice_choice, choice: "answer", prompt: "feedback")
#       ans.question = @question
#       ans.run = @runs[idx]
#       ans.save!
#     end
#     @page = @activity.pages.first
#     @page.add_embeddable(@question, nil, CRater::ARG_SECTION_NAME)
#   end

#   def create_collaboration_run
#     @c_run = FactoryGirl.create(:collaboration_run)
#     @c_run.user = @users[0]
#     @c_run.runs.concat(@runs)
#     @c_run.save!
#   end

#   describe "CRater::FeedbackSubmission.generate_feedback" do
#     it "generates submission, feedback items and returns basic information about submission" do
#       info = CRater::FeedbackSubmission.generate_feedback(@page, @runs[0])
#       expect(CRater::FeedbackSubmission.count).to eql(1)
#       expect(info[:submission_id]).to eql(CRater::FeedbackSubmission.first.id)
#       expect(info[:feedback_items][@answers[0].answer_id][:text]).to eql('feedback')
#     end

#     describe "when user runs activity with collaborators" do
#       before(:each) do
#         create_collaboration_run
#       end

#       it "copies submission and feedback items to other runs" do
#         info = CRater::FeedbackSubmission.generate_feedback(@page, @runs[0])
#         expect(CRater::FeedbackSubmission.count).to eql(2)
#         expect(info[:submission_id]).to eql(CRater::FeedbackSubmission.first.id)
#         expect(info[:feedback_items][@answers[0].answer_id][:text]).to eql('feedback')
#         expect(info[:feedback_items][@answers[1].answer_id]).to be_nil # it's other user answer!

#         submission = CRater::FeedbackSubmission.first
#         submission_copy = CRater::FeedbackSubmission.last
#         expect(submission_copy.base_submission).to eql(submission)

#         expect(submission.run).to eql(@runs[0])
#         expect(submission_copy.run).to eql(@runs[1])

#         expect(submission.feedback_items.count).to eql(1)
#         expect(submission.feedback_items.first.feedback_text).to eql('feedback')
#         expect(submission.feedback_items.first.answer).to eql(@answers[0])
#         expect(submission_copy.feedback_items.count).to eql(1)
#         expect(submission_copy.feedback_items.first.feedback_text).to eql('feedback')
#         expect(submission_copy.feedback_items.first.answer).to eql(@answers[1])
#       end
#     end
#   end

#   describe "#update_usefulness_score" do
#     let(:submission) do
#       info = CRater::FeedbackSubmission.generate_feedback(@page, @runs[0])
#       CRater::FeedbackSubmission.find(info[:submission_id])
#     end

#     it "updates usefulness_score attribute" do
#       submission.update_usefulness_score(99)
#       expect(submission.usefulness_score).to eql(99)
#     end

#     describe "when user runs activity with collaborators" do
#       before(:each) do
#         create_collaboration_run
#       end

#       it "updates usefulness_score attribute of all related submissions" do
#         submission.update_usefulness_score(99)
#         expect(CRater::FeedbackSubmission.count).to eql(2)
#         CRater::FeedbackSubmission.all.each do |s|
#           expect(s.usefulness_score).to eql(99)
#         end
#       end
#     end
#   end
# end
