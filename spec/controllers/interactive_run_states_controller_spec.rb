require 'spec_helper'

def make(thing); end

def expect_response_has_valid_raw_data(response)
  expect(response.body).to match /"raw_data":"{\\"bar\\": 1}"/
end

def expect_response_is_not_authorized(response, reason)
  expect(response.body).to eq "{\"success\":false,\"message\":\"You are not authorized to get the requested owned interactive run state because you are not #{reason}.\"}"
end

describe Api::V1::InteractiveRunStatesController do
  let(:activity)              { FactoryGirl.create(:activity)       }
  let(:interactive)           { FactoryGirl.create(:mw_interactive) }
  let(:user)                  { FactoryGirl.create(:user)           }
  let(:run)                   { FactoryGirl.create(:run, {activity: activity, user: user})}
  let(:run_data)              {'{"bar": 1}'}
  let(:interactive_run_state) { FactoryGirl.create(:interactive_run_state, {run: run, interactive: interactive, raw_data: run_data, key: 'foo'})}

  before(:each) do
    make interactive_run_state
  end

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({:get => "api/v1/interactive_run_states/foo"}).to route_to(:controller => 'api/v1/interactive_run_states', :action => 'show', :key => "foo")
    end
    it 'recognizes and generates #update' do
      expect({:put => "api/v1/interactive_run_states/foo"}).to route_to(:controller => 'api/v1/interactive_run_states', :action => 'update', :key => "foo")
    end
  end

  describe 'show' do

    it 'renders 404 when the interactive run state does not exist' do
      begin
        get :show, :key => 'bar'
      rescue ActiveRecord::RecordNotFound
      end
    end

    describe 'when a user is not logged in' do

      describe 'unowned documents' do
        let(:run) { FactoryGirl.create(:run, {activity: activity, user: nil})}

        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end

      describe 'owned documents' do
        it 'cannot be opened' do
          get :show, :key => 'foo'
          expect_response_is_not_authorized(response, "logged in")
        end
      end

    end

    describe 'when a non-admin user is logged in' do
      before(:each) do
        sign_in user
      end

      describe 'unowned documents' do
        let(:run) { FactoryGirl.create(:run, {activity: activity, user: nil})}

        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end

      describe 'owned documents that the user owns' do
        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end

      describe 'owned documents that the user does not own' do
        let(:user2) { FactoryGirl.create(:user)           }
        let(:run)   { FactoryGirl.create(:run, {activity: activity, user: user2})}

        it 'cannot be opened' do
          get :show, :key => 'foo'
          expect_response_is_not_authorized(response, "the owner or an admin")
        end
      end
    end

    describe 'when a admin user is logged in' do
      let(:user) { FactoryGirl.create(:user, {is_admin: true})           }

      before(:each) do
        sign_in user
      end

      describe 'unowned documents' do
        let(:run) { FactoryGirl.create(:run, {activity: activity, user: nil})}

        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end

      describe 'owned documents that the user owns' do
        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end

      describe 'owned documents that the user does not own' do
        let(:user2)  { FactoryGirl.create(:user)           }
        let(:run)    { FactoryGirl.create(:run, {activity: activity, user: user2})}

        it 'can be opened' do
          get :show, :key => 'foo'
          expect_response_has_valid_raw_data(response)
        end
      end
    end
  end
end
