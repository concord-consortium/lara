# require 'spec_helper'

# describe Embeddable::LabbookAnswersController do
#   before(:each) do
#     stub_request(:any, endpoint)
#   end

#   let(:question) { Embeddable::Labbook.create! }
#   let(:answer)   { Embeddable::LabbookAnswer.create!(question: question, run: run) }
#   let(:endpoint) { 'http://concord.portal.org' }
#   let(:user)     { FactoryGirl.create(:user) }

#   describe '#update' do
#     describe 'with a run initiated from remote portal' do
#       describe 'and logged in' do
#         let(:run) { FactoryGirl.create(:run, remote_endpoint: endpoint, user_id: user.id) }
#         it 'should fire off a web request to update the portal' do
#           sign_in user
#           put 'update', id: answer.id
#           expect(response.status).not_to eq 401
#           assert_requested :post, endpoint
#         end
#       end
#       describe 'and anonymous' do
#         let(:run) { FactoryGirl.create(:run, remote_endpoint: endpoint, user_id: nil) }
#         it 'should fire off a web request to update the portal' do
#           put 'update', id: answer.id
#           expect(response.status).not_to eq 401
#           assert_requested :post, endpoint
#         end
#       end
#     end
#   end

#   describe 'with no endpoint defined (not requested from portal)' do
#     describe 'and logged in' do
#       let(:run) { FactoryGirl.create(:run, user_id: user.id) }
#       it 'should not fire a web request to update the portal' do
#         sign_in user
#         put 'update', id: answer.id
#         expect(response.status).not_to eq 401
#         assert_not_requested :post, endpoint
#       end
#     end
#     describe 'and anonymous' do
#       let(:run) { FactoryGirl.create(:run, user_id: nil) }
#       it 'should not fire a web request to update the portal' do
#         put 'update', id: answer.id
#         expect(response.status).not_to eq 401
#         assert_not_requested :post, endpoint
#       end
#     end
#   end
# end
