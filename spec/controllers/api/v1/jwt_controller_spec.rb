require 'spec_helper'

describe Api::V1::JwtController do
  let(:endpoint_url)  { "http://fake.blarg.com/blarg/1" }
  let(:stubbed_token) { 'foo' }
  let(:user)          { stub_model(User, :is_admin => false) }
  let(:activity)      { FactoryGirl.create(:activity) }
  let(:run) {
    r = FactoryGirl.create(:run, remote_endpoint: endpoint_url, user: user)
    r.activity = activity
    r.save
    r
  }
  let(:post_results) { OpenStruct.new(body: {token: 'fake-token'} ) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Concord::AuthPortal).to receive(:auth_token_for_url).and_return(stubbed_token)
    allow(HTTParty).to receive(:post).and_return post_results
  end

  describe 'get_firebase_jwt' do
    describe 'with a run' do
      it "should fail with 404 if the run is not found" do
        post :get_firebase_jwt, :run_id => run.id + 1
        expect(response.status).to eq(404)
      end

      describe 'with no endpoint' do
        let(:endpoint_url)    { nil }
        it "should fail with 500" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq('Run has no remote_endpoint')
        end
      end

      describe 'with no current user' do
        before(:each) do
          allow(controller).to receive(:current_user).and_return(nil)
        end
        it "should fail with 500" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq('Anonymous runs cannot request a JWT')
        end
      end

      describe 'with a different non-admin current user' do
        let(:different_user) { stub_model(User, :is_admin => false) }
        before(:each) do
          allow(controller).to receive(:current_user).and_return(different_user)
        end
        it "should fail with 500" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq('You are not the owner of the run or an admin')
        end
      end

      describe 'with no auth_token for the remote endpoint' do
        before(:each) do
          allow(Concord::AuthPortal).to receive(:auth_token_for_url).and_raise("No portal!")
        end
        it "should fail with 500" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq('No portal!')
        end
      end

      describe 'with the current user owning the run' do
        it "should succeed" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          expect(json_response["token"]).to eq('fake-token')
        end
      end

      describe 'with an admin user not owning a run' do
        let(:admin_user) { stub_model(User, :is_admin => true) }
        before(:each) do
          allow(controller).to receive(:current_user).and_return(admin_user)
        end

        it "should succeed" do
          post :get_firebase_jwt, :run_id => run.id
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          expect(json_response["token"]).to eq('fake-token')
        end
      end
    end

    describe "without a run" do
      describe "without portal info" do
        let(:error) { 'Session has no portal_domain and portal_user_id' }
        it "should fail with 500 if there is no portal info in the session" do
          post :get_firebase_jwt
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq(error)
        end

        it "should fail with 500 if there is only a portal_domain in the session" do
          post :get_firebase_jwt, {portal_domain: "foo"}
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq(error)
        end

        it "should fail with 500 if there is only a portal_user in the session" do
          post :get_firebase_jwt, {portal_user: "bar"}
          expect(response.status).to eq(500)
          json_response = JSON.parse(response.body)
          expect(json_response["response_type"]).to eq('ERROR')
          expect(json_response["error"]).to eq(error)
        end
      end

      it "should fail with 500 if the portal domain is unknown" do
        allow(Concord::AuthPortal).to receive(:portal_for_url).and_return(nil)
        post :get_firebase_jwt, {}, {portal_domain: "foo", portal_user_id: "bar"}
        expect(response.status).to eq(500)
        json_response = JSON.parse(response.body)
        expect(json_response["response_type"]).to eq('ERROR')
        expect(json_response["error"]).to eq('No portal found for portal_domain (foo) in session')
      end

      it "should succeed with a known portal domain and portal user id" do
        allow(Concord::AuthPortal).to receive(:portal_for_url).and_return(OpenStruct.new({ url: "http://fake.portal.com" }))
        post :get_firebase_jwt, {}, {portal_domain: "foo", portal_user_id: "bar"}
        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response["token"]).to eq('fake-token')
      end
    end
  end
end
