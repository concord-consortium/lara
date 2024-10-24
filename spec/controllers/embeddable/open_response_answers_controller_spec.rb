# require 'spec_helper'

# describe Embeddable::OpenResponseAnswersController do
#   before(:each) do
#     stub_request(:any, endpoint)
#   end

#   let(:question) { FactoryGirl.create(:open_response, :prompt => "prompt", :default_text => "default text") }
#   let(:answer)   { FactoryGirl.create(:or_answer, :question => question, :run => run) }
#   let(:endpoint) { 'http://concord.portal.org' }
#   let(:user)     { FactoryGirl.create(:user) }

#   describe "#update" do
#     describe "with a run initiated from remote portal" do
#       describe "and logged in" do
#         let(:run)  {
#           FactoryGirl.create(
#             :run,
#             :remote_endpoint => endpoint,
#             :user_id => user.id
#           )
#         }
#         describe "with default params" do
#           let(:new_answer) { question.default_text }
#           it "should not update the answer with default text" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answer_text).to eq(nil)
#           end
#         end
#         describe "with valid params" do
#           let(:new_answer) { "this answer has been changed "}
#           it "should update the answer" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answer_text).to eq(new_answer)
#           end
#           it "should fire off a web request to update the portal" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             assert_requested :post, endpoint
#           end
#         end
#       end
#       describe "and anonymous" do
#         let(:run)  {
#           FactoryGirl.create(
#             :run,
#             :remote_endpoint => endpoint,
#             :user_id => nil
#           )
#         }
#         describe "with default params" do
#           let(:new_answer) { question.default_text }
#           it "should not update the answer with default text" do
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answer_text).to eq(nil)
#           end
#         end
#         describe "with valid params" do
#           let(:new_answer) { "this answer has been changed "}
#           it "should update the answer" do
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answer_text).to eq(new_answer)
#           end
#           it "should fire off a web request to update the portal" do
#             post "update", :id => answer.id, :embeddable_open_response_answer => {
#               :answer_text => new_answer
#             }
#             expect(response.status).not_to eq 401
#             assert_requested :post, endpoint
#           end
#         end
#       end
#     end
#   end

#   describe "with no endpoint defined (not requested from portal)" do
#     describe "with valid params" do
#       describe "and logged in" do
#         let(:run)      { FactoryGirl.create(:run, user_id: user.id) }
#         let(:new_answer) { "this answer has been changed "}
#         it "should update the answer" do
#           sign_in user
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           answer.reload
#           expect(answer.answer_text).to eq(new_answer)
#         end
#         it "shouldn't fire a web request to update the portal" do
#           sign_in user
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           assert_not_requested :post, endpoint
#         end
#       end
#       describe "and anonymous" do
#         let(:run)      { FactoryGirl.create(:run, user_id: nil) }
#         let(:new_answer) { "this answer has been changed "}
#         it "should update the answer" do
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           answer.reload
#           expect(answer.answer_text).to eq(new_answer)
#         end
#         it "shouldn't fire a web request to update the portal" do
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           assert_not_requested :post, endpoint
#         end
#       end
#     end

#     describe "with default params" do
#       describe "and logged in" do
#         let(:run)      { FactoryGirl.create(:run, user_id: user.id) }
#         let(:new_answer) { question.default_text }
#         it "should update the answer" do
#           sign_in user
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           answer.reload
#           expect(answer.answer_text).to eq(nil)
#         end
#         it "shouldn't fire a web request to update the portal" do
#           sign_in user
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           assert_not_requested :post, endpoint
#         end
#       end
#       describe "and anonymous" do
#         let(:run)      { FactoryGirl.create(:run, user_id: nil) }
#         let(:new_answer) { question.default_text }
#         it "should update the answer" do
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           answer.reload
#           expect(answer.answer_text).to eq(nil)
#         end
#         it "shouldn't fire a web request to update the portal" do
#           post "update", :id => answer.id, :embeddable_open_response_answer => {
#             :answer_text => new_answer
#           }
#           expect(response.status).not_to eq 401
#           assert_not_requested :post, endpoint
#         end
#       end
#     end
#   end
# end
