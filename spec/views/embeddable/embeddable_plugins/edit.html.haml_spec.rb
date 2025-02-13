require 'spec_helper'

describe "embeddable/embeddable_plugins/edit", type: :view do
  it_behaves_like "attached to embeddable form" do
    let(:test_embeddable) { Embeddable::EmbeddablePlugin.create(args) }
  end
end
