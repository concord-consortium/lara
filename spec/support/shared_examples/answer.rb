shared_examples "an answer" do
  let (:run)      { mock_model(Run) }
  let (:answer)   { described_class.create }

  describe "question_index" do
    describe "without a run" do
      it "should return nil" do
        answer.question_index.should be_nil
      end
    end

    describe "with a run" do
      it "should return its index within the run" do
        question = mock("question")
        answer.stub(:run => run)
        answer.stub(:question => question)
        run.stub_chain(:activity,:questions,:index).and_return 3
        answer.question_index.should == 4
      end
    end
  end

  describe "prompt_no_itals" do
    let (:answer_a) { described_class.create }
    let (:answer_b) { described_class.create }

    it "strips the content from any HTML `i` containers in the prompt" do
      test_html = "<h1> this is a test</h1> <p> <i>with</i> italics </p>"
      expected  = "<h1> this is a test</h1> <p> <i></i> italics </p>"
      answer.stub(:prompt => test_html)
      answer.prompt_no_itals.should == expected
    end

    it "should work for two consecutive calls on different objects" do
      answer_a.stub(:prompt => '<i>Prompt</i> A')
      answer_b.stub(:prompt => '<i>Prompt</i> B')
      answer_a.prompt_no_itals.should == '<i></i> A'
      answer_b.prompt_no_itals.should == '<i></i> B'
    end
  end

  describe '#question_index' do
    let (:question) { mock("question") }
    it 'returns nil if there is no activity' do
      answer.run = nil
      answer.save
      answer.reload.question_index.should be_nil
    end

    it 'returns an integer reflecting position among all questions for the activity' do
      answer.run = run
      answer.stub(:question => question)

      q1   = mock_model(Embeddable::OpenResponse)
      q2   = mock_model(Embeddable::OpenResponse)
      q3   = mock_model(Embeddable::MultipleChoice)
      q4   = mock_model(Embeddable::MultipleChoice)
      activity = mock_model(LightweightActivity, :questions => [q1, q2, q3, q4, question])
      run.stub(:activity => activity)

      answer.question_index.should be(5)

      # Order changes should be respected
      activity.stub(:questions => [q1, q2, q3, question, q4])
      answer.reload
      answer.run = run
      answer.stub(:question => question)
      answer.question_index(true).should be(4)
    end
  end

  describe "send_to_portal" do
    describe "with a run" do
      it "should call run.send_to_portal(self, nil)" do
        answer.stub(:run => run)
        run.should_receive(:queue_for_portal).with(answer)
        answer.send_to_portal
        answer.should be_dirty
      end
    end

    describe "with out a run" do
      it "wont call run.send_to_portal(self)" do
        run.should_not_receive(:queue_for_portal).with(answer)
        answer.send_to_portal
      end
    end
  end

  describe "to_json" do
    let(:question) { mock("question", :id => 3)}

    it "should be the portal_hash to_json" do
      # this isn't actually testing anythign useful at all
      answer.stub(:question => question)
      answer.to_json.should == answer.portal_hash.to_json
    end
  end

  describe "reset_to_clean" do
    let(:answer) { described_class.create(:is_dirty => true) }
    it "should remove the is_dirty flag without invoking callbacks" do
      answer.should_not_receive(:queue_for_portal)
      answer.mark_clean
      answer.reload
      answer.should_not be_dirty
    end
  end


end