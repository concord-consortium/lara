require 'spec_helper'

describe Embeddable::MultipleChoiceAnswersController do
  before(:each) do
    stub_request(:any, "http://foo.bar.fake/baz")
  end
  let(:a_answer) { FactoryGirl.create(:multiple_choice_choice, :choice => "a" )}
  let(:b_answer) { FactoryGirl.create(:multiple_choice_choice, :choice => "a" )}
  let(:c_answer) { FactoryGirl.create(:multiple_choice_choice, :choice => "a" )}
  let(:choices)  { [a_answer,b_answer,c_answer] }
  let(:question) { FactoryGirl.create(:multiple_choice, :prompt => "prompt", :choices => choices)}
  let(:endpoint) { "http://foo.bar.fake/baz"    }
  let(:run)      { FactoryGirl.create(:run)     }
  let(:answer)   { FactoryGirl.create(:multiple_choice_answer, :question => question, :run => run)}

  describe "#update" do
    describe "with a run initiated from remote portlal" do
      let(:run)  {
        FactoryGirl.create(
          :run,
          :remote_endpoint => endpoint
        )
      }
      describe "with valid params" do
        it "should update the answer" do
          post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
            :answers => [a_answer.id]
          }
          answer.reload
          answer.answers.should == [a_answer]
        end
        it "should fire off a web request to update the portal" do
          post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
            :answers => [a_answer.id]
          }
          assert_requested :post, endpoint
        end
      end
    end
    describe "with a run without a remote endpoint (not run from portal)" do
      let(:run)  {
        FactoryGirl.create(
          :run,
          :remote_endpoint => nil
        )
      }
      describe "with valid params" do
        it "should update the answer" do
          post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
            :answers => [a_answer.id]
          }
          answer.reload
          answer.answers.should == [a_answer]
        end

        it 'should accept multiple answers if provided' do
          post 'update', :id => answer.id, :embeddable_multiple_choice_answer => {
            :answers => [b_answer.id, c_answer.id]
          }
          answer.reload
          answer.answers.should == [b_answer, c_answer]
        end

        it "should fire off a web request to update the portal" do
          post "update", :id => answer.id, :embeddable_multiple_choice_answer => {
            :answers => [a_answer.id]
          }
          assert_not_requested :post, endpoint
        end
      end
    end
  end


end