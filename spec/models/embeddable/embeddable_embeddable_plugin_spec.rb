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
          approved_script_label: plugin.approved_script.label
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
  end

end
