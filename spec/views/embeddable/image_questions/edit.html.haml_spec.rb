require 'spec_helper'

describe "embeddable/image_questions/edit.html.haml" do
  it_behaves_like "attached to interactive form" do
    let(:test_embeddable) { Embeddable::ImageQuestion.create(args) }
  end
end
