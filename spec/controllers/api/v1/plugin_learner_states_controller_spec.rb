require 'spec_helper'

def json_response_body
  return JSON.parse(response.body)
end

describe Api::V1::PluginLearnerStatesController do
  let(:plugin_id)     { 400 }
  let(:run_id)        { 442 }

  let(:user_opts) do
    {
      id: 42,
      email: "student@school.edu",
      admin?: false,
      author?: false,
      is_project_admin?: false
    }
  end

  let(:user2_opts) do
    {
      id: 44,
      email: "student@school.edu",
      admin?: false,
      author?: false,
      is_project_admin?: false
    }
  end

  let(:run_opts) do
    {
      id: run_id,
      user: user,
      user_id: user.id
    }
  end

  let(:plugin_opts) do
    {
      id: plugin_id,
      shared_learner_state_key: nil
    }
  end

  let(:user)   { mock_model User, user_opts }
  let(:user2)  { mock_model User, user2_opts }
  let(:run)    { mock_model Run, run_opts }
  let(:plugin) { mock_model Plugin, plugin_opts }
  let(:state)  { 'state_value' }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Run).to receive(:find).and_return(run)
    allow(Plugin).to receive(:find).and_return(plugin)
    pstate = PluginLearnerState.find_or_create(plugin, run)
    pstate.update_attribute(:state, state)
  end

  describe "When a user of a run uses a plugin" do
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
    end
    describe 'to load state' do
      it "they should get their state" do
        post :load, run_id: run_id, plugin_id: plugin_id
        expect(response.status).to eq(200)
        expect(json_response_body['state']).to eq(state)
      end
    end

    describe 'to save state' do
      it "they should save their state" do
        post :save, run_id: run_id, plugin_id: plugin_id, state: "new_state"
        expect(response.status).to eq(200)
        expect(json_response_body['state']).to eq("new_state")
      end
    end
  end

  describe "When a user tries to use a plugin on someone elses run" do
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user2)
    end
    describe 'to load state' do
      it "they should not get the state from the other user" do
        post :load, run_id: run_id, plugin_id: plugin_id
        expect(response.status).to eq(403)
      end
    end

    describe 'to save state' do
      it "they should not be able to save over the other users state" do
        post :save, run_id: run_id, plugin_id: plugin_id, state: "new_state"
        expect(response.status).to eq(403)
      end
    end
  end

  describe "for an anonymous user using a pliugin for someone elses run" do
    before(:each) do
      allow(controller).to receive(:current_user).and_return(nil)
    end

    describe 'to load state' do
      it "they should be prevented from seeing someone elses state" do
        post :load, run_id: run_id, plugin_id: plugin_id
        expect(response.status).to eq(403)
      end
    end

    describe 'to save state' do
      it "should not allow anonymous user to save over other users state" do
        post :save, run_id: run_id, plugin_id: plugin_id, state: "new_state"
        expect(response.status).to eq(403)
      end
    end

    describe "for an anonymous user using a plugin in their own run" do
      let(:run_opts) do
        {
          id: run_id,
          user: nil,
          user_id: nil
        }
      end
      describe 'to load state' do
        it "they should be able to load their state" do
          post :load, run_id: run_id, plugin_id: plugin_id
          expect(response.status).to eq(200)
        end
      end

      describe 'to save state' do
        it "they should be able to save their state" do
          post :save, run_id: run_id, plugin_id: plugin_id, state: "new_state"
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
