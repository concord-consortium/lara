require 'spec_helper'

describe VideoSource do
  let (:video) { FactoryGirl.create(:video_source) }

  it 'has valid attributes' do
    video.should be_valid
    video.url = nil
    video.should_not be_valid
    video.url = 'http://example.com/video.ogg'
    video.format = 'video/ogg'
    video.should be_valid
    video.format = 'i_made_this_up'
    video.should_not be_valid
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { url: video.url, format: video.format }
      video.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new instance of VideoSource with identical attributes' do
      video.duplicate.should be_a_new(VideoSource).with( url: video.url, format: video.format )
    end
  end
end
