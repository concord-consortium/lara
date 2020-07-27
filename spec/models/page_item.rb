require 'spec_helper'

# NOTE: this also tests the LinkedPageItem

describe PageItem do

  let (:interactive1) { FactoryGirl.create(:mw_interactive) }
  let (:interactive2) { FactoryGirl.create(:mw_interactive) }
  let (:interactive3) { FactoryGirl.create(:mw_interactive) }
  let (:interactive4) { FactoryGirl.create(:mw_interactive) }
  let (:page) { FactoryGirl.create(:page) }

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

  def add_linked_interactive(primary, secondary)
    FactoryGirl.create(:linked_page_item, {primary: primary.page_item, secondary: secondary.page_item})
  end

end
