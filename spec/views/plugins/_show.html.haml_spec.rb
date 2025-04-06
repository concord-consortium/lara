require 'spec_helper'

describe "plugins/_show.html.haml" do
  let(:version) { 3 }
  let(:shared_learner_state_key) { 'shared-learner-state-key-is-a-string' }
  let(:class_info_url) { 'http://class-info.url/'}
  let(:email) { 'fake-user-name@fake-domain.com' }
  let(:user_id)  { 123 }
  let(:run_id)   { 123 }
  let(:run_remote_endpoint) { nil }
  let(:approved_script_id){ 447 }
  let(:plugin_id){ 123 }
  let(:plugin_name){ 'plugin-name' }
  let(:plugin_label) {'plugin-label'}
  let(:plugin_url) { 'http://plugin.com/plugin.js' }
  let(:plugin_author_data){ "{'name': 'plugin-name'}" }
  let(:embeddable_local) do
    double(
      id: 42
    )
  end
  let(:user) do
    double({
      email: email,
      id: user_id
    })
  end
  let(:run) do
    double({
      user: user,
      id: run_id,
      class_info_url: class_info_url,
      remote_endpoint: run_remote_endpoint,
      activity: FactoryBot.create(:activity)
    })
  end
  let(:plugin_local) do
    double( "Fake Plugin",
      name: plugin_name,
      label: plugin_label,
      id: plugin_id,
      url: plugin_url,
      version: version,
      author_data: plugin_author_data,
      shared_learner_state_key: shared_learner_state_key,
      approved_script: double(
        id: approved_script_id
      )
    )
  end
  let(:_locals) do
    {
      plugin: plugin_local,
    }
  end

  let(:common_plugin_code) do
    [
      /name: '#{plugin_name}'/,
      /url: '#{plugin_url}'/,
      /pluginId: #{plugin_id}/,
      /runId: #{run_id}/,
      /userEmail: '#{email}'/,
      /classInfoUrl: '#{class_info_url}'/,
      /remoteEndpoint: null/,
      /container:/,
      /wrappedEmbeddable: embeddableContext/,
      /LARA\.Plugins\.initPlugin\('plugin#{approved_script_id}', pluginContext\)/,
    ]
  end

  before(:each) do
    @run = run
    render partial: "plugins/show", locals: _locals
  end

  context "when rendered from as an activity level plugin" do
    it "should render a javascript to call Plugins.initPlugin with correct values" do
      activity_level_code = common_plugin_code + [
        /embeddableContext = null/,
        /embeddablePluginId: null/
      ]

      activity_level_code.each do |expected_string|
        expect(CGI.unescapeHTML(rendered)).to match(expected_string)
      end
    end

    context "when the run doesn't have an id like during a 'print_blank' route" do
      let(:run_id) { nil }

      it "should render the javascript" do
        common_plugin_code.each do |expected_string|
          expect(CGI.unescapeHTML(rendered)).to match(expected_string)
        end
      end
    end

  end

  context "when rendered as a page level plugin that is not wrapping an embeddable" do
    let (:_locals) do
      {
        plugin: plugin_local,
        embeddable: embeddable_local
      }
    end

    it "should render a javascript to call Plugins.initPlugin with correct values" do
      page_level_code = common_plugin_code + [
        /embeddableContext = null/,
        /embeddablePluginId: 42/
      ]
      page_level_code.each do |expected_string|
        expect(CGI.unescapeHTML(rendered)).to match(expected_string)
      end
    end
  end

  context "when rendered as a page level plugin that is wrapping an embeddable" do
    let (:_locals) do
      {
        plugin: plugin_local,
        embeddable: embeddable_local,
        wrapped_embeddable: double( "Fake wrapped embeddable",
          id: 78,
          embeddable_dom_id: 123,
          export: {}
        )
      }
    end

    it "should render a javascript to call Plugins.initPlugin with correct values" do
      page_level_code = common_plugin_code + [
        /embeddableContext = {/,
        /embeddablePluginId: 42/
      ]
      page_level_code.each do |expected_string|
        expect(CGI.unescapeHTML(rendered)).to match(expected_string)
      end
    end
  end


end
