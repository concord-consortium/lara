shared_examples "attached to embeddable form" do

  let(:page) { FactoryBot.create(:page) }
  let(:args) { {} }

  before :each do
    page.add_embeddable(test_embeddable)
  end

  describe "edit form" do
    it "includes author data and full width checkbox" do
      assign(:embeddable, test_embeddable)
      render
      expect(rendered).to have_field("embeddable_embeddable_plugin[author_data]")
      expect(rendered).to have_field("embeddable_embeddable_plugin[is_half_width]")
    end
  end
end
