require 'spec_helper'

describe MwInteractive do
  let (:interactive) { FactoryGirl.create(:mw_interactive) }
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    interactive.valid?
  end

  it 'can to associate an interactive page' do

    page.add_interactive(interactive)

    interactive.reload
    page.reload

    expect(interactive.interactive_page).to eq(page)
  end

  it 'returns an aspect ratio based on native height and native width' do
    expect(interactive.aspect_ratio).to be === 1.3241379310344827
    interactive.native_width = 500
    interactive.native_height = 250
    interactive.save
    expect(interactive.aspect_ratio).to be === 2
  end

  it 'returns a calculated height from a supplied width, based on aspect ratio' do
    expect(interactive.height(800)).to be === 604.1666666666666
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = {
        name: interactive.name,
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        save_state: interactive.save_state,
        has_report_url: interactive.has_report_url,
        click_to_play: interactive.click_to_play,
        image_url: interactive.image_url,
        is_hidden: interactive.is_hidden
       }
      expect(interactive.to_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'is a new instance of MwInteractive with values' do
      interactive.is_hidden = true
      expect(interactive.duplicate).to be_a_new(MwInteractive).with({
        name: "Copy of #{interactive.name}",
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        click_to_play: interactive.click_to_play,
        image_url: interactive.image_url,
        is_hidden: interactive.is_hidden
      })
    end
  end

  # This approach is temporary, it is specific for ITSI style authoring.
  # It allows authors to select a special interactive, and then the labbook automatically becomes an
  # uploading labbook
  # If we keep the data modeling for this, then this code should be moved to the ITSI style authoring
  # javascript code.
  # Better yet would be to find another way to model and/or author this.
  describe 'labbook options' do
    let (:labbook) { FactoryGirl.create(:labbook, action_type: Embeddable::Labbook::SNAPSHOT_ACTION, custom_action_label: "custom action label") }
    let (:interactive) { FactoryGirl.create(:mw_interactive, labbook: labbook) }

    it 'remain the same if url changes to a non-upload only url' do
      stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
      interactive.url = 'not_an_upload_url'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::SNAPSHOT_ACTION)
      expect(interactive.labbook.custom_action_label).to eq("custom action label")
    end

    describe 'change to upload options if url changes' do
      it 'to an upload only url' do
        stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
        interactive.url = 'upload_url2'
        interactive.save
        expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
        expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      end
      it 'to an upload only url with spaces in the environment variable' do
        stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => '   upload_url1  |  upload_url2 '})
        interactive.url = 'upload_url1'
        interactive.save
        expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
        expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      end
    end

    it 'revert from upload options if url changes from an upload only url' do
      stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
      interactive.url = 'upload_url1'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
      expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      interactive.url = 'not_an_upload_url'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::SNAPSHOT_ACTION)
      expect(interactive.labbook.custom_action_label).to eq(nil)
    end
  end
end
