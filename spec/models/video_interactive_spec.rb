require 'spec_helper'

describe VideoInteractive do
  let (:video_interactive) { FactoryGirl.create(:video_interactive) }
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    video_interactive.valid?
  end

  it 'can associate to an interactive page' do
    page.add_interactive(video_interactive)

    video_interactive.reload
    page.reload

    video_interactive.interactive_page.should == page
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { poster_url: video_interactive.poster_url, caption: video_interactive.caption, credit: video_interactive.credit }
      video_interactive.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'is a new instance of VideoInteractive with values' do
      video_interactive.duplicate.should be_a_new(VideoInteractive).with( poster_url: video_interactive.poster_url, caption: video_interactive.caption, credit: video_interactive.credit )
    end
  end
end
