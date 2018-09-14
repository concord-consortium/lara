require 'spec_helper'

def json_response_body
  return JSON.parse(response.body)
end

describe Api::V1::PluginLearnerStatesController do
  let(:plugin_id)     { 400 }
  let(:run_id)        { 442 }

  let(:user_opts) do
    { id: 42}
  end

  let(:run_opts) do
    {
      id: run_id,
      user: user
    }
  end

  let(:plugin_opts) do
    {
      id: plugin_id,
      shared_learner_state_key: nil
    }
  end

  let(:user)   { double("User",   user_opts) }
  let(:run)    { double("Run",    run_opts) }
  let(:plugin) { double("Plugin", plugin_opts) }
  let(:state)  { 'state_value' }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Run).to receive(:find).and_return(run)
    allow(Plugin).to receive(:find).and_return(plugin)
    pstate = PluginLearnerState.find_or_create(plugin, run)
    pstate.update_attribute(:state, state)
  end

  describe 'load' do
    it "should load data" do
      post :load, run_id: run_id, plugin_id: plugin_id
      expect(response.status).to eq(200)
      expect(json_response_body['state']).to eq("state_value")
    end
  end
  
  describe 'save' do
    it "should save data, and return the same data" do
      post :save, run_id: run_id, plugin_id: plugin_id, state: "new_state"
      expect(response.status).to eq(200)
      expect(json_response_body['state']).to eq("new_state")
    end
  end
end
