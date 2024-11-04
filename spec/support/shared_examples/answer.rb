shared_examples "an answer" do
  let (:run)      { mock_model(Run) }
  let (:answer)   { described_class.create }

  describe "question_index" do
    describe "without a run" do
      it "should return nil" do
        expect(answer.question_index).to be_nil
      end
    end
  end

  describe "prompt_no_itals" do
    let (:answer_a) { described_class.create }
    let (:answer_b) { described_class.create }

    it "strips the content from any HTML `i` containers in the prompt" do
      test_html = "<h1> this is a test</h1> <p> <i>with</i> italics </p>"
      expected  = "<h1> this is a test</h1> <p> <i></i> italics </p>"
      allow(answer).to receive_messages(prompt: test_html)
      expect(answer.prompt_no_itals).to eq(expected)
    end

    it "should work for two consecutive calls on different objects" do
      allow(answer_a).to receive_messages(prompt: '<i>Prompt</i> A')
      allow(answer_b).to receive_messages(prompt: '<i>Prompt</i> B')
      expect(answer_a.prompt_no_itals).to eq('<i></i> A')
      expect(answer_b.prompt_no_itals).to eq('<i></i> B')
    end
  end

  describe "send_to_portal" do
    describe "with a run" do
      it "should call run.send_to_portal(self, nil)" do
        allow(answer).to receive_messages(run: run)
        expect(run).to receive(:queue_for_portal)
        answer.send_to_portal
        expect(answer).to be_dirty
      end
    end

    describe "with out a run" do
      it "wont call run.send_to_portal(self)" do
        expect(run).not_to receive(:queue_for_portal)
        answer.send_to_portal
      end
    end
  end

  describe "reset_to_clean" do
    let(:answer) { described_class.create(is_dirty: true) }
    it "should remove the is_dirty flag without invoking callbacks" do
      expect(answer).not_to receive(:queue_for_portal)
      answer.mark_clean
      answer.reload
      expect(answer).not_to be_dirty
    end
  end


end