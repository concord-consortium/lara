require 'spec_helper'

ruby_uuid_regex = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
describe Plugin do

  let(:activity_opts)        {  {}  }
  let(:approved_script_opts) do
    {
      name: "test approved script",
      url: "https://example.com/plugin.js",
      label: "testscript",
      description: "This is a test script",
      version: "1.0.0",
      json_url: "https://example.com/manifest.json",
      authoring_metadata: "{}"
    }
  end

  let(:shared_learner_state_key)  {'global-plugin-id'}

  let(:activity)        { mock_model LightweightActivity, activity_opts }
  let(:approved_script) { FactoryBot.create(:approved_script, approved_script_opts) }
  let(:description)     { "description" }
  let(:author_data)     { "authored_data" }
  let(:component_label) { "component_label" }
  let(:plugin_opts) do
    {
      shared_learner_state_key: shared_learner_state_key,
      description: description,
      author_data: author_data,
      approved_script: approved_script,
      component_label: component_label
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
          id: plugin.id,
          description: description,
          author_data: author_data,
          approved_script_label: approved_script.label,
          component_label: component_label,
          approved_script: {
            name: approved_script.name,
            url: approved_script.url,
            label: approved_script.label,
            description: approved_script.description,
            version: approved_script.version,
            json_url: approved_script.json_url,
            authoring_metadata: approved_script.authoring_metadata
          }
        }
      )
    end
  end

  describe "#duplicate" do
    let(:copy) { plugin.duplicate }
    describe "when the approved script exists" do
      it "should create an almost identical copy of the plugin" do
        [:description, :author_data, :approved_script_id].each do |atr|
            expect(copy.send atr).to eql(plugin.send atr)
        end
      end
    end
    describe "when the associated approved script does not exist" do
      before(:each) do
        expect(ApprovedScript).to receive(:find_by_label).and_return(nil)
      end
      it "should create an almost identical copy of the plugin" do
        [:description, :author_data ].each do |atr|
            expect(copy.send atr).to eql(plugin.send atr)
        end
      end
      it "the copy should not include a reference to an approved script" do
        expect(copy.approved_script_id).to be_nil
      end
    end
  end


end
