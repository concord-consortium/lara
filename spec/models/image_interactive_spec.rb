require 'spec_helper'

describe ImageInteractive do
  let (:image_interactive) { FactoryGirl.create(:image_interactive) }
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    image_interactive.valid?
  end

  it 'can to associate an interactive page' do
    page.add_interactive(image_interactive)

    image_interactive.reload
    page.reload

    image_interactive.interactive_page.should == page
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { url: image_interactive.url, caption: image_interactive.caption, credit: image_interactive.credit }
      image_interactive.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'is a new instance of ImageInteractive with values' do
      image_interactive.duplicate.should be_a_new(ImageInteractive).with( url: image_interactive.url, caption: image_interactive.caption, credit: image_interactive.credit )
    end
  end
end
