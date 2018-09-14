require 'spec_helper'

ruby_uuid_regex = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
describe Plugin do

  let(:activity_opts)        {  {}  }
  let(:approved_script_opts) do
    {}
  end

  let(:shared_learner_state_key)  {'global-plugin-id'}

  let(:activity)           { mock_model LightweightActivity, activity_opts }
  let(:approved_script)    { mock_model ApprovedScript, approved_script_opts}
  let(:description)        { "description" }
  let(:author_data)        { "authored_data" }
  let(:plugin_opts) do
    {
      shared_learner_state_key: shared_learner_state_key,
      # plugin_scope: activity,
      description: description,
      author_data: author_data,
      approved_script: approved_script
    }
  end

  let(:plugin)      { Plugin.create(plugin_opts) }

  describe "creation" do
    it "should have a plugin" do
      expect(plugin).to be_instance_of Plugin
    end
  end

  describe "generating default shared_learner_state_key" do
    let(:shared_learner_state_key) { nil }
    it "should be filled in with an automatic uuid value" do
      expect(plugin.shared_learner_state_key).not_to eql('')
      expect(plugin.shared_learner_state_key).to match(ruby_uuid_regex)
    end
  end

  describe "to_hash" do
    it "should respond with serialized params" do
      expect(plugin.to_hash).to include(
        {
          description: description,
          author_data: author_data,
          approved_script_id: approved_script.id,
          shared_learner_state_key: shared_learner_state_key
        }
      )
    end
  end

  describe "#duplicate" do
    let(:copy) { plugin.duplicate }
    it "should create an almost identical copy of the plugin" do
      [:description, :author_data, :approved_script_id,
        :shared_learner_state_key].each do |attribute|
          expect(copy.send attribute).to eql(plugin.send attribute)
      end
    end
  end


end
