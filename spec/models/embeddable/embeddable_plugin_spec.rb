require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::EmbeddablePlugin do
  it_behaves_like "attached to embeddable"

  let (:is_full_width) {true}
  let (:is_hidden) {true}
  let (:plugin) { FactoryGirl.create(:plugin) }
  let (:params) do
    {
      is_hidden: is_hidden,
      is_full_width: is_full_width,
      plugin: plugin
    }
  end
  let (:embeddable_plugin) { FactoryGirl.create(:embeddable_plugin, params) }

  it "should create a new instance with default values" do
    expect(embeddable_plugin).to be_valid
  end

  describe '#to_hash' do
    it 'has saves interesting attributes' do
      expected = {
        plugin: {
          description: plugin.description,
          author_data: plugin.author_data,
          approved_script_label: plugin.approved_script.label,
          component_label: plugin.component_label,
          approved_script: {
            name: plugin.approved_script.name,
            url: plugin.approved_script.url,
            label: plugin.approved_script.label,
            description: plugin.approved_script.description,
            version: plugin.approved_script.version,
            json_url: plugin.approved_script.json_url,
            authoring_metadata: plugin.approved_script.authoring_metadata
          }
        },
        is_hidden: true,
        is_full_width: true
      }
      expect(embeddable_plugin.to_hash).to eq(expected)
    end
  end

  describe "#export" do
    let(:hash_data){ emb.export }
    let(:emb) { embeddable_plugin }
    it 'preserves is_hidden' do
      emb.is_hidden = true
      expect(hash_data[:is_hidden]).to eq true
    end
    it 'preserves is_full_width' do
      emb.is_full_width = true
      expect(hash_data[:is_full_width]).to eq true
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(embeddable_plugin.duplicate).to be_a_new(Embeddable::EmbeddablePlugin)
      .with({
        is_full_width: is_full_width,
        is_hidden: is_hidden
      })
    end
    it "the new instance's plugin is setup correctly" do
      duplicate = embeddable_plugin.duplicate

      # this the page level duplicate fuction calls save like this
      duplicate.save!(validate: false)
      duplicate.reload
      expect(duplicate.plugin.plugin_scope).to eq(duplicate)
    end

  end

  describe '#import' do
    let(:example_json_file) { 'activity_with_arg_block_section' }
    let(:activity_json) do
      JSON.parse(File.read(
        Rails.root +
        "spec/import_examples/#{example_json_file}.json"),
        :symbolize_names => true)
    end

    let(:test_page_index) { 0 }
    let(:page_json) { activity_json[:pages][test_page_index] }
    let(:page) { InteractivePage.import(page_json)}

    it 'sets the plugin_scope of the associated plugin' do
      embeddable = page.embeddables.find{|e| e.is_a? Embeddable::EmbeddablePlugin}
      expect(embeddable).to_not be_nil
      expect(embeddable.plugin.plugin_scope).to eq(embeddable)
    end

  end

  describe 'delegated to plugin methods' do
    it 'should save value after a simple create, set, save, reload' do
      embeddable = Embeddable::EmbeddablePlugin.create!
      embeddable.approved_script_id = "123"
      embeddable.save!
      embeddable.reload
      expect(embeddable.approved_script_id).to eq("123")
    end
  end

  describe '#show_in_edit?' do
    it 'returns true by default' do
      expect(embeddable_plugin.show_in_edit?).to eq(true)
    end
    it 'returns false if a embeddable is wrapped' do
      embeddable_plugin.embeddable = FactoryGirl.create(:open_response)
      expect(embeddable_plugin.show_in_edit?).to eq(false)
    end
  end
end
