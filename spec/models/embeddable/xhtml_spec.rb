require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Xhtml do
  let (:xhtml) { FactoryGirl.create(:xhtml) }

  describe 'HTML validation' do
    it 'rejects invalid HTML' do
      xhtml.content = '<p>This is invalid but parseable HTML.<p>Tag soup, ugh!</p>'
      xhtml.valid?.should be_true # Ugh, but this is HTML not XML
      xhtml.content = '<p class="bad_attribute>This is also invalid.</p>'
      xhtml.valid?.should be_false
      xhtml.content = 'This is valid.'
      xhtml.valid?
    end
  end

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