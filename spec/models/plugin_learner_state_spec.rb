require 'spec_helper'

describe PluginLearnerState do

  let(:user)        { double "user", {id: 42} }
  let(:run_opts)    { {user: user, id: 4242} }
  let(:run)         { double "Run", run_opts }

  let(:shared_learner_state_key)  {'global-plugin-id'}

  let(:plugin_opts) do
    {
      id: 3,
      shared_learner_state_key: shared_learner_state_key,
      run: run
    }
  end

  let(:plugin)      { double "Plugin", plugin_opts}

  before(:each) do
    @plugin_learner_state = PluginLearnerState.find_or_create(plugin, run)
    @strategy = PluginLearnerState.get_lookup_strategy(plugin, run)
  end

  describe "With a plugin that shares data across unlinked activities" do
    describe "When the user is logged in" do
      it "should find the learner's data using the shared_learner_state_key and user_id" do
        expect(@strategy).to be_instance_of(PluginLearnerState::SharedStateKeyAndUser)
        expect(@plugin_learner_state).to be_instance_of(PluginLearnerState)
      end
    end

    describe "When the user is anonymous" do
      let(:user) { nil }
      it "should find the learner's data using the shared_learner_state_key and run_id" do
        expect(@strategy).to be_instance_of(PluginLearnerState::SharedStateKeyAndRun)
        expect(@plugin_learner_state).to be_instance_of(PluginLearnerState)
      end
    end
  end

  describe "With a plugin that silos data between assignments" do
    let(:shared_learner_state_key) { '' }
    # or this let(:shared_learner_state_key) { nil }
    describe "When the user is logged in" do
      it "should find the learner's data using the plugin_id and run_id" do
        expect(@strategy).to be_instance_of(PluginLearnerState::PluginAndRun)
        expect(@plugin_learner_state).to be_instance_of(PluginLearnerState)
      end
    end
 
    describe "When the user is anonymous" do
      it "should find the learner's data using the plugin_id and run_id" do
        expect(@strategy).to be_instance_of(PluginLearnerState::PluginAndRun)
        expect(@plugin_learner_state).to be_instance_of(PluginLearnerState)
      end
    end
  end

end
