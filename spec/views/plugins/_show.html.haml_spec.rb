require 'spec_helper'

describe "plugins/_show.html.haml" do
  let(:version) { 3 }
  let(:shared_learner_state_key) { 'shared-learner-state-key-is-a-string' }
  let(:class_info_url) { 'http://class-info.url/'}
  let(:email) { 'fake-user-name@fake-domain.com' }
  let(:user_id)  { 123 }
  let(:run_id)   { 123 }
  let(:run_remote_endpoint) { nil }
  let(:plugin_id){ 123 }
  let(:plugin_name){ 'plugin-name' }
  let(:plugin_label) {'plugin-label'}
  let(:plugin_url) { 'http://plugin.com/plugin.js' }
  let(:plugin_author_data){ "{'name': 'plugin-name'}" }
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
      remote_endpoint: run_remote_endpoint
    })
  end
  let(:_locals) do
    {
      # plugins: double(),
      plugin: double({
        name: plugin_name,
        label: plugin_label,
        id: plugin_id,
        url: plugin_url,
        version: version,
        author_data: plugin_author_data,
        shared_learner_state_key: shared_learner_state_key
      })
    }
  end

  before(:each) do
    @run = run
    render partial: "plugins/show", locals: _locals
  end

  it "should render a javascript to call Plugins.initPlugin with values" do
    [
      /name: '#{plugin_name}'/,
      /url: '#{plugin_url}'/,
      /pluginId: #{plugin_id}/,
      /runId: #{run_id}/,
      /userEmail: '#{email}'/,
      /classInfoUrl: '#{class_info_url}'/,
      /remoteEndpoint: null/,
      /container:/,
      /wrappedEmbeddable:/,
      /LARA\.InternalAPI\.initPlugin\('plugin123', pluginContext\)/,
    ].each do |expected_string|
      expect(rendered).to match(expected_string)
    end
  end
end
