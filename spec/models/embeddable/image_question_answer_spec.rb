require 'spec_helper'

describe Embeddable::ImageQuestionAnswer do
  let(:question){ FactoryGirl.create(:image_question) }
  let(:run)     { FactoryGirl.create(:run, :activity => FactoryGirl.create(:activity) ) }

  let(:answer)  do
    FactoryGirl.create(:image_question_answer,
      :question    => question,
      :run => run )
  end

  describe "model associations" do
    it "should belong to an open response" do
      answer.question = question
      answer.save
      answer.reload.question.should == question
      question.reload.answers.should include answer
    end

    it "should belong to a run" do
      answer.reload.run.should == run
      run.reload.image_question_answers.should include answer
    end
  end

  describe '#portal_hash' do
    let(:expected) do
      {
        "type"        => "image_question",
        "question_id" => question.id.to_s,
        "answer"      => answer.answer_text,
        "image_url"   => answer.image_url
      }
    end

    it "matches the expected hash" do
      answer.portal_hash.should == expected
    end
  end

  describe '#question_index' do
    it 'returns nil if there is no activity' do
      answer.run = nil
      answer.save
      answer.reload.question_index.should be_nil
    end

    it 'returns an integer reflecting position among all questions for the activity' do
      page1 = FactoryGirl.create(:page, :name => "Page 1", :lightweight_activity => run.activity)
      page2 = FactoryGirl.create(:page, :name => "Page 2", :lightweight_activity => run.activity)
      page3 = FactoryGirl.create(:page, :name => "Page 3", :lightweight_activity => run.activity)

      mc1 = FactoryGirl.create(:mc_with_choices, :name => 'One')
      mc2 = FactoryGirl.create(:mc_with_choices, :name => 'Two')
      mc3 = FactoryGirl.create(:mc_with_choices, :name => 'Three')

      or1 = FactoryGirl.create(:open_response, :name => 'one')
      or2 = FactoryGirl.create(:open_response, :name => 'two')
      or3 = FactoryGirl.create(:open_response, :name => 'three')

      page1.add_embeddable(mc1)
      page1.add_embeddable(or1)
      page2.add_embeddable(or2)
      page2.add_embeddable(mc2)
      page3.add_embeddable(mc3)
      page3.add_embeddable(or3)

      page2.add_embeddable(question)

      answer.question_index.should be(5)

      # Order changes should be respected
      join = PageItem.find_by_interactive_page_id_and_embeddable_id(page2.id, or2.id)
      join.move_to_bottom # i.e. move or2 into position 5 and bump our answer up to position 4
      answer.reload
      answer.question_index.should be(4)
    end
  end

  describe '#prompt_no_itals' do
    it 'strips the content from any HTML `i` containers in the prompt' do
      question.prompt = '<p>This prompt is <i>not</i> free of italicized content.</p>'
      answer.prompt_no_itals.should_not match /not/
    end
  end

  describe "delegated methods" do
    describe "prompt" do
      it "should delegate to question" do
        question = mock_model(Embeddable::ImageQuestion)
        question.should_receive(:prompt).and_return(:some_prompt)
        answer.question = question
        answer.prompt.should == :some_prompt
      end
    end
  end

end
