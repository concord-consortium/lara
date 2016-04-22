require 'spec_helper'


describe QuestionTracker do
  let(:tested_class) { QuestionTracker }
  subject { tested_class }

  describe "class methods" do
    it { should respond_to :new }
    it { should respond_to :create }
  end

  describe "instance methods" do
    let(:master_question) { FactoryGirl.create(:multiple_choice, prompt: "master question prompt") }
    let(:question)        { FactoryGirl.create(:multiple_choice, prompt: "another question")       }
    let(:props) do
      {
          master_question: master_question,
          name: 'my tracked question',
          description: 'my tracked question description'
      }
    end

    let(:instance) { tested_class.create props }

    it "should have the right master_question" do
      instance.master_question.should eql master_question
      master_question.reload.master_for_tracker.should eql instance
    end

    it "should include the master question in the questions list" do
      instance.questions.size.should eql 1
      instance.questions.should include(master_question)
    end

    describe "add_question" do
      before(:each) { instance.add_question(question) }
      describe "when the question is the same type as the master_question" do
        it "s questions should include the newly added question" do
          instance.questions.should include(question)
        end
        describe "when the question is already in the list" do
          it "shouldn't add it again" do
            count = instance.questions.size
            instance.add_question(question)
            instance.questions.size.should eql(count)
          end
        end
      end

      describe "when the question is of the wrong type" do
        let(:question)        {  FactoryGirl.create :open_response }
        it "s questions should not include the newly added question" do
          instance.questions.should_not include(question)
        end
      end

    end

    describe "remove_question" do
      let(:question) { Embeddable::MultipleChoice.new()}
      describe "when the question is in the list" do
        before(:each) { instance.add_question(question) }
        it "s questions should include the newly added question" do
          instance.remove_question(question)
          instance.questions.should_not include(question)
        end
        it "the question should still exists" do
          instance.remove_question(question)
          question.reload.should be_persisted
        end
      end
    end

    describe "new_question" do
      before(:each) { instance.new_question(); instance.new_question()   }
      it "should duplicate the master question" do
        instance.questions.size.should eql 3 # 2 duplicates plus the master
        instance.questions.each do |question|
          question.prompt.should eql master_question.prompt
        end
      end
    end

  end
end
