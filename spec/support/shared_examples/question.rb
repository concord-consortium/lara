shared_examples "a question" do
  let(:act)  { FactoryGirl.create(:activity_with_page) }
  let(:page) { act.pages.first }

  def add_question
    q = described_class.create
    page.add_embeddable(q)
    q
  end

  describe "#index_in_activity" do
    it "should return question position in the activity" do
      q1 = add_question
      q2 = add_question
      q3 = add_question
      expect(q1.index_in_activity(act)).to eql(1)
      expect(q2.index_in_activity(act)).to eql(2)
      expect(q3.index_in_activity(act)).to eql(3)
    end
  end
end
