require 'spec_helper'

describe VideoSource do
  let (:video) { FactoryBot.create(:video_source) }

  it 'has valid attributes' do
    expect(video).to be_valid
    video.url = nil
    expect(video).not_to be_valid
    video.url = 'http://example.com/video.ogg'
    video.format = 'video/ogg'
    expect(video).to be_valid
    video.format = 'i_made_this_up'
    expect(video).not_to be_valid
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { url: video.url, format: video.format }
      expect(video.to_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'returns a new instance of VideoSource with identical attributes' do
      expect(video.duplicate).to be_a_new(VideoSource).with( url: video.url, format: video.format )
    end
  end
end
