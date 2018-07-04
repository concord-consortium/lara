require 'spec_helper'

describe "embeddable/labbooks/edit.html.haml" do
  it_behaves_like "attached to interactive form" do
    let(:test_embeddable) { Embeddable::Labbook.create(args) }
  end
end
