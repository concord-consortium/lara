require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::AnswerFinder do
  let(:open_response)  { FactoryGirl.create(:open_response)  }
  let(:multiple_choice){ FactoryGirl.create(:multiple_choice)}
  let(:html)           { FactoryGirl.create(:xhtml)          }
  let(:image)          { FactoryGirl.create(:image_question) }
  let(:run)            { FactoryGirl.create(:run)            }

  describe "#find_answer" do

    context "when there is no existing answer" do
      it "should make a new answer of the right type" do
        finder = Embeddable::AnswerFinder.new(run)
        answer = finder.find_answer(open_response)
        answer.should be_an_instance_of Embeddable::OpenResponseAnswer
        answer = finder.find_answer(multiple_choice)
        answer.should be_an_instance_of Embeddable::MultipleChoiceAnswer
        answer = finder.find_answer(image)
        answer.should be_an_instance_of Embeddable::ImageQuestionAnswer
      end

      context 'when the question is an ImageQuestion with an author-defined background' do
        it 'copies the bg_url of the question as the image_url of the answer' do
          image.bg_source = 'Drawing'
          image.bg_url = 'http://concord.org/sites/default/files/images/news/2013/bright-ideas-06262013t.jpg'
          finder = Embeddable::AnswerFinder.new(run)
          answer = finder.find_answer(image)
          answer.image_url.should == image.bg_url
        end
      end
    end

    context "with an existing answer" do
      it "should return the same answer" do
        finder = Embeddable::AnswerFinder.new(run)
        answer = finder.find_answer(open_response)
        answer.answer_text = "xyzzy"
        answer.save
        run.reload
        finder = Embeddable::AnswerFinder.new(run)
        answer2 = finder.find_answer(open_response)
        answer.id.should == answer2.id
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
