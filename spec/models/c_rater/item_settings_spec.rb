require 'spec_helper'

describe CRater::ItemSettings do
  
  let(:item_settings) do
    item_settings = FactoryGirl.create(:item_settings)
    item_settings.save
    item_settings
  end
  
  describe '#to_hash' do
    it 'has values from the source instance' do
      expected = {
        item_id: item_settings.item_id,
        score_mapping_id: item_settings.score_mapping_id
      }
      expect(item_settings.to_hash).to eq(expected)
    end
  end
  
  describe '#export' do
    it 'returns json of an item_setting' do
      item_settings_json = item_settings.export.as_json
      expect(item_settings_json['item_id']).to eq(item_settings.item_id)
      expect(item_settings_json['score_mapping_id']).to eq(item_settings.score_mapping_id)
    end
  end
  
  describe '#duplicate' do
    it 'returns a new item_setting with values from the source instance' do
      dup_settings = item_settings.duplicate
      expect(dup_settings).to be_a(CRater::ItemSettings)
      expect(dup_settings.item_id).to eq(item_settings.item_id)
      expect(dup_settings.score_mapping_id).to eq(item_settings.score_mapping_id)
    end
  end
  
  describe '#import' do
    it 'imports item_settings from json' do
      activity_json = JSON.parse(File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import_v1.json'), :symbolize_names => true)
      activity_json[:pages].each do |p|
        if p[:sections]
          p[:sections].each do |sec|
            if sections[:section_embeddables]
              sections[:section_embeddables].each do |embed|
                if embed[:item_settings]
                  import_settings = CRater::ItemSettings.import(embed[:item_settings])
                  expect(import_settings).to be_a(CRater::ItemSettings)
                  expect(embed[:item_settings][:item_id]).to eq(import_settings.item_id)
                  expect(embed[:item_settings][:score_mapping_id]).to eq(import_settings.score_mapping_id)
                end
              end
            end
          end
        end
      end
    end
  end
end