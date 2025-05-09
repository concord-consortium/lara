require 'spec_helper'

# NOTE: this also tests the LinkedPageItem

describe PageItem do

  let (:interactive1) { FactoryBot.create(:mw_interactive) }
  let (:interactive2) { FactoryBot.create(:mw_interactive) }
  let (:interactive3) { FactoryBot.create(:mw_interactive) }
  let (:interactive4) { FactoryBot.create(:mw_interactive) }
  let (:page) { FactoryBot.create(:page) }

  before :each do
    page.add_interactive(interactive1)
    page.add_interactive(interactive2)
    page.add_interactive(interactive3)
    page.add_interactive(interactive4)
    interactive1.reload
    interactive2.reload
    interactive3.reload
    interactive4.reload
    page.reload
  end

  it 'exists on interactives' do
    expect(interactive1.page_item).not_to be_nil
    expect(interactive1.page_item.interactive_page).to eq page
    expect(interactive1.page_item.embeddable).to eq interactive1
  end

  it 'can link interactives' do
    add_linked_interactive(interactive1, interactive2)
    add_linked_interactive(interactive1, interactive3)
    add_linked_interactive(interactive4, interactive1)
    expect(interactive1.page_item.primary_linked_items.length).to eq 2
    expect(interactive1.page_item.secondary_linked_items.length).to eq 1
  end

  it 'is destroyed along with link interactives when interactive is destroyed' do
    add_linked_interactive(interactive1, interactive2)
    add_linked_interactive(interactive1, interactive3)
    add_linked_interactive(interactive4, interactive1)

    page_item_id = interactive1.page_item.id
    primary_ids = interactive1.page_item.primary_linked_items.select {|li| li.id}
    secondary_ids = interactive1.page_item.secondary_linked_items.select {|li| li.id}

    expect(PageItem.where(id: page_item_id).length).to eq 1
    expect(LinkedPageItem.where(id: primary_ids).length).to eq 2
    expect(LinkedPageItem.where(id: secondary_ids).length).to eq 1

    interactive1.destroy()

    expect(PageItem.where(id: page_item_id).length).to eq 0
    expect(LinkedPageItem.where(id: primary_ids).length).to eq 0
    expect(LinkedPageItem.where(id: primary_ids).length).to eq 0
  end

  describe 'duplicate' do
    let(:page_item) { page.page_items.first }
    describe 'on a page' do
      it 'should create a new pageItem' do
        expect(page.page_items.length).to eq 4
        first_page_item = page.page_items.first
        first_page_item.duplicate
        page.reload
        expect(page.page_items.length).to eq 5

        # Each embeddable should have its own uniq id:
        embed_ids = page.page_items.map(&:embeddable_id)
        expect(embed_ids.uniq.length).to eq 5

        # Each embeddable should have its own uniq position
        embed_positions = page.page_items.map(&:position)
        expect(embed_positions.uniq.length).to eq 5
      end
    end

    describe "it copies the embeddables associations" do
      let(:helper) { spy('helper') }
      let(:embeddable) { Embeddable::OpenResponse.new }
      before(:each) do
        helper.stub(:get_copy) { embeddable }
        page_item.stub(:embeddable) { embeddable }
        embeddable.stub(:embeddable=) { true }
        embeddable.stub(:embeddable) { true }
        embeddable.stub(:interactive=) { true }
        embeddable.stub(:interactive) { true }
        embeddable.stub(:linked_interactive=) { true }
        embeddable.stub(:linked_interactive) { true }
      end

      it "it calls `get_copy` for all of the associations" do
        page_item.duplicate(helper)
        expect(helper).to have_received(:get_copy).at_least(4).times
      end
    end
  end
end
