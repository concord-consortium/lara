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
end
