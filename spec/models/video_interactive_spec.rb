require 'spec_helper'

describe VideoInteractive do
  let (:video_interactive) { FactoryBot.create(:video_interactive) }
  let (:page) { FactoryBot.create(:page) }
  let (:source) { FactoryBot.create(:video_source) }

  it 'has valid attributes' do
    video_interactive.valid?
  end

  it 'can associate to an interactive page' do
    page.add_interactive(video_interactive)

    video_interactive.reload
    page.reload

    expect(video_interactive.interactive_pages.first).to eq(page)
  end

  it 'may have sources' do
    source_count = video_interactive.sources.length
    video_interactive.sources << source
    expect(video_interactive.sources.length).to be(source_count + 1)
    expect(video_interactive.sources.last).to be(source)
    expect(source.video_interactive_id).to be(video_interactive.id)
  end

  describe '#aspect_ratio' do
    it 'returns a ratio of width to height' do
      # Default values
      expect(video_interactive.height).to be(240)
      expect(video_interactive.width).to be(556)
      expect(video_interactive.aspect_ratio).to eq(2.316666666666667)
    end
  end

  describe '#calculated_height' do
    it 'uses #aspect_ratio to return a height given a width' do
      expect(video_interactive.aspect_ratio).to eq(2.316666666666667)
      expect(video_interactive.calculated_height(695).to_i).to be(300)
    end
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = {
        poster_url: video_interactive.poster_url,
        caption: video_interactive.caption,
        credit: video_interactive.credit,
        width: video_interactive.width,
        height: video_interactive.height,
        is_hidden: video_interactive.is_hidden,
        is_half_width: video_interactive.is_half_width
      }
      expect(video_interactive.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    it 'returns json of a video interactive' do
      video_interactive_json = video_interactive.export.as_json
      expect(video_interactive_json['sources'].length).to eq(video_interactive.sources.count)
    end
  end

  describe '#duplicate' do
    it 'is a new instance of VideoInteractive with values' do
      video_interactive.is_hidden = true
      expect(video_interactive.duplicate).to be_a_new(VideoInteractive).with({
        poster_url: video_interactive.poster_url,
        caption: video_interactive.caption,
        credit: video_interactive.credit,
        width: video_interactive.width,
        height: video_interactive.height,
        is_hidden: video_interactive.is_hidden})
    end
  end
end
