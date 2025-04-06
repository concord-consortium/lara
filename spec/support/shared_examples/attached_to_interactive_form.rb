shared_examples "attached to interactive form" do
  def interactive_choice_select_css
    "li.interactive_choice select option"
  end

  def no_interactive_text
    AttachedToInteractive::NO_INTERACTIVE_LABEL
  end

  let(:interactive_a)  { FactoryBot.create(:mw_interactive) }
  let(:interactive_b)  { FactoryBot.create(:mw_interactive) }
  let(:interactives)   { [] }
  let(:page)           { FactoryBot.create(:page_with_or, interactives: interactives) }
  let(:args)           { {} }

  before :each do
    page.add_embeddable(test_embeddable)
  end

  describe "without any interactives on the page" do
    it "includes one choice for 'no interactive'" do
      assign(:embeddable, test_embeddable)
      render
      expect(rendered).to have_css(
        interactive_choice_select_css,
        text: no_interactive_text)
    end
  end

  describe "with two interactives on the page" do
    let(:interactives)  {[interactive_a,interactive_b]}
    it "includes three choices" do
      assign(:embeddable, test_embeddable)
      render
      expect(rendered).to have_css interactive_choice_select_css, count: 3
    end
  end
end
