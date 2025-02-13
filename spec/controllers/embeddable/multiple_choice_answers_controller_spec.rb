# require 'spec_helper'

# describe Embeddable::MultipleChoiceAnswersController do
#   before(:each) do
#     stub_request(:any, endpoint)
#   end
#   let(:a_answer) { FactoryBot.create(:multiple_choice_choice, :choice => "a" )}
#   let(:b_answer) { FactoryBot.create(:multiple_choice_choice, :choice => "a" )}
#   let(:c_answer) { FactoryBot.create(:multiple_choice_choice, :choice => "a" )}
#   let(:choices)  { [a_answer,b_answer,c_answer] }
#   let(:question) { FactoryBot.create(:multiple_choice, :prompt => "prompt", :choices => choices)}
#   let(:endpoint) { 'http://concord.portal.org' }
#   let(:run)      { FactoryBot.create(:run)     }
#   let(:answer)   { FactoryBot.create(:multiple_choice_answer, :question => question, :run => run)}
#   let(:user)     { FactoryBot.create(:user) }

#   describe "#update" do
#     describe "with a run initiated from remote portal" do
#       describe "and logged in" do
#         let(:run)  {
#           FactoryBot.create(
#             :run,
#             :remote_endpoint => endpoint,
#             :user_id => user.id
#           )
#         }

#         describe "with valid params" do
#           it "should update the answer" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([a_answer])
#           end

#           it "should fire off a web request to update the portal" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             assert_requested :post, endpoint
#           end
#         end

#         describe "missing params" do
#           it "shouldn't throw an error" do
#             sign_in user
#             post "update", :id => answer.id
#             expect(response.status).not_to eq 401
#           end
#           it "should create an admin event" do
#             expect(AdminEvent).to receive(:create).and_return(true)
#             sign_in user
#             post "update", :id => answer.id
#             expect(response.status).not_to eq 401
#           end
#         end
#       end
#       describe "and anonymous" do
#         let(:run)  {
#           FactoryBot.create(
#             :run,
#             :remote_endpoint => endpoint,
#             :user_id => nil
#           )
#         }

#         describe "with valid params" do
#           it "should update the answer" do
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([a_answer])
#           end

#           it "should fire off a web request to update the portal" do
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             assert_requested :post, endpoint
#           end
#         end

#         describe "missing params" do
#           it "shouldn't throw an error" do
#             post "update", :id => answer.id
#             expect(response.status).not_to eq 401
#           end
#           it "should create an admin event" do
#             expect(AdminEvent).to receive(:create).and_return(true)
#             post "update", :id => answer.id
#             expect(response.status).not_to eq 401
#           end
#         end
#       end
#     end

#     describe "with a run without a remote endpoint (not run from portal)" do
#       describe "and logged in" do
#         let(:run)  {
#           FactoryBot.create(
#             :run,
#             :remote_endpoint => nil,
#             :user_id => user.id
#           )
#         }

#         describe "with valid params" do
#           it "should update the answer" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([a_answer])
#           end

#           it 'should accept multiple answers if provided' do
#             sign_in user
#             post 'update', :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [b_answer.id, c_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([b_answer, c_answer])
#           end

#           it "should fire off a web request to update the portal" do
#             sign_in user
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             assert_not_requested :post, endpoint
#           end
#         end
#       end
#       describe "and anonymous" do
#         let(:run)  {
#           FactoryBot.create(
#             :run,
#             :remote_endpoint => nil,
#             :user_id => nil
#           )
#         }

#         describe "with valid params" do
#           it "should update the answer" do
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([a_answer])
#           end

#           it 'should accept multiple answers if provided' do
#             post 'update', :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [b_answer.id, c_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             answer.reload
#             expect(answer.answers).to eq([b_answer, c_answer])
#           end

#           it "should fire off a web request to update the portal" do
#             post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
#               :answers => [a_answer.id]
#             }
#             expect(response.status).not_to eq 401
#             assert_not_requested :post, endpoint
#           end
#         end
#       end
#     end
#   end
# end
