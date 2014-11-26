require 'spec_helper'

describe VideoInteractive do
  let (:video_interactive) { FactoryGirl.create(:video_interactive) }
  let (:page) { FactoryGirl.create(:page) }
  let (:source) { FactoryGirl.create(:video_source) }

  it 'has valid attributes' do
    video_interactive.valid?
  end

  it 'can associate to an interactive page' do
    page.add_interactive(video_interactive)

    video_interactive.reload
    page.reload

    video_interactive.interactive_page.should == page
  end

  it 'may have sources' do
    source_count = video_interactive.sources.length
    video_interactive.sources << source
    video_interactive.sources.length.should be(source_count + 1)
    video_interactive.sources.last.should be(source)
    source.video_interactive_id.should be(video_interactive.id)
  end

  describe '#aspect_ratio' do
    it 'returns a ratio of width to height' do
      # Default values
      video_interactive.height.should be(240)
      video_interactive.width.should be(556)
      video_interactive.aspect_ratio.should == 2.316666666666667
    end
  end

  describe '#calculated_height' do
    it 'uses #aspect_ratio to return a height given a width' do
      video_interactive.aspect_ratio.should == 2.316666666666667
      video_interactive.calculated_height(695).to_i.should be(300)
    end
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { poster_url: video_interactive.poster_url, caption: video_interactive.caption, credit: video_interactive.credit, width: video_interactive.width, height: video_interactive.height }
      video_interactive.to_hash.should == expected
    end
  end

  describe '#export' do
    it 'returns json of a video interactive' do
      video_interactive_json = video_interactive.export.as_json
      video_interactive_json['sources'].length.should == video_interactive.sources.count
    end 
  end

  describe '#duplicate' do
    it 'is a new instance of VideoInteractive with values' do
      video_interactive.duplicate.should be_a_new(VideoInteractive).with( poster_url: video_interactive.poster_url, caption: video_interactive.caption, credit: video_interactive.credit, width: video_interactive.width, height: video_interactive.height )
    end
  end
end
