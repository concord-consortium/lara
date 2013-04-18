require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::AnswerFinder do
  let(:open_response)  { FactoryGirl.create(:open_response)  }
  let(:multiple_choice){ FactoryGirl.create(:multiple_choice)}
  let(:html)           { FactoryGirl.create(:xhtml)          }
  let(:run)            { FactoryGirl.create(:run)            }

  describe "#find_answer" do

    context "when there is no existing answer" do
      it "should make a new answer of the right type" do
        finder = Embeddable::AnswerFinder.new(run)
        answer = finder.find_answer(open_response)
        answer.should be_an_instance_of Embeddable::OpenResponseAnswer
        answer = finder.find_answer(open_response)
        answer.should be_an_instance_of Embeddable::OpenResponseAnswer
      end
    end

    context "with an existing answer" do
      it "should return the same answer" do
        finder = Embeddable::AnswerFinder.new(run)
        answer = finder.find_answer(open_response)
        answer.answer_text = "xyzzy"
        answer.save
        answer2 = finder.find_answer(open_response)
        answer.should == answer2
        answer2.answer_text.should == "xyzzy"
      end
    end

    context "for Embeddables that dont support answers" do
      it "should return the Embeddable itself" do
        finder = Embeddable::AnswerFinder.new(run)
        answer = finder.find_answer(html)
        answer.should == html # embeddable was returned as-is
      end
    end
  end
end
