require 'spec_helper'

describe "embeddable/labbooks/edit.html.haml" do

  def interactive_choice_select_css
    "li.interactive_choice > select > option"
  end

  let(:interactive_a)  { FactoryGirl.create(:mw_interactive) }
  let(:interactive_b)  { FactoryGirl.create(:mw_interactive) }
  let(:interactives)   { [] }
  let(:page)           { FactoryGirl.create(:page_with_or, interactives: interactives) }
  let(:args)           { {} }

  let(:labbook)      do
    lbook = Embeddable::Labbook.create(args)
    page.add_embeddable(lbook)
    lbook
  end

  describe "without any interactives on the page" do
    it "doesn't include any choices" do
      assign(:embeddable, labbook)
      render
      expect(rendered).not_to have_css interactive_choice_select_css
    end
  end

  describe "with two interactives on the page" do
    let(:interactives)  {[interactive_a,interactive_b]}
    it "includes two some choices" do
      assign(:embeddable, labbook)
      render
      expect(rendered).to have_css interactive_choice_select_css, count: 2
    end
  end

end
