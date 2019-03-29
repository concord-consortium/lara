require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::ExternalScript do
  let (:props)  { {} }
  let (:script) { Embeddable::ExternalScript.create(props) }

  # address bug:  undefined method `is_hidden?'
  describe '#is_hidden?' do
    it "should be a method returning false" do
      expect(script).to respond_to(:is_hidden?)
      expect(script.is_hidden?).to eq(false)
    end
  end

end
