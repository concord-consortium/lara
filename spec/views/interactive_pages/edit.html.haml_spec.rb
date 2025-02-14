require 'spec_helper'

describe "interactive_pages/edit" do
  let(:activity)  { stub_model(LightweightActivity, id: 1, name: 'Stub activity')}

  let (:page) do
    p = FactoryBot.create(:page, name: "fake page", lightweight_activity: activity, embeddable_display_mode: 'carousel')
    allow(p).to receive_messages(last?: true)
    [3,1,2].each do |i|
      embed = FactoryBot.create(:xhtml, name: "embeddable #{i}", content: "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end

  let (:page1) { page }
  let (:page2) { FactoryBot.create(:page, name: 'Another fake page', lightweight_activity: activity ) }

  before :each do
    assign(:activity, activity)
    assign(:page, page)
    assign(:all_pages, [page])
  end

  it 'has wrapper for react element' do
    render
    expect(rendered).to match(/<div id='sections-container'>/)
  end

end
