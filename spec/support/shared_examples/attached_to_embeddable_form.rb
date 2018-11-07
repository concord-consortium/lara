shared_examples "attached to embeddable form" do
  def embeddable_choice_select_css
    "select.select_embeddable option"
  end

  def no_embeddable_text
    AttachedToEmbeddable::NO_EMBEDDABLE_LABEL
  end

  let(:embeddable_a)  { FactoryGirl.create(:open_response) }
  let(:embeddable_b)  { FactoryGirl.create(:open_response) }
  let(:embeddables)   { [] }
  let(:page)           { FactoryGirl.create(:page, embeddables: embeddables) }
  let(:args)           { {} }

  before :each do
    page.add_embeddable(test_embeddable)
  end

  describe "without any embeddables on the page" do
    it "includes one choice for 'no embeddable'" do
      assign(:embeddable, test_embeddable)
      render
      expect(rendered).to have_css(
        embeddable_choice_select_css,
        text: no_embeddable_text)
    end
  end

  describe "with two embeddables on the page" do
    let(:embeddables)  {[embeddable_a,embeddable_b]}
    it "includes three choices" do
      assign(:embeddable, test_embeddable)
      render
      expect(rendered).to have_css embeddable_choice_select_css, count: 3
    end
  end
end
