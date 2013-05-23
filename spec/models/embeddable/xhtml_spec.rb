require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Xhtml do
  let (:xhtml) { FactoryGirl.create(:xhtml) }

  describe '#to_hash' do
    it 'returns useful attributes' do
      expected = { name: xhtml.name, content: xhtml.content }
      xhtml.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      xhtml.duplicate.should be_a_new(Embeddable::Xhtml).with( name: xhtml.name, content: xhtml.content )
    end
  end
end