require 'spec_helper'

describe Embeddable::OpenResponseAnswersController do
  before(:each) do
    stub_request(:any, "http://foo.bar.fake/baz")
  end

  let(:question) { FactoryGirl.create(:open_response, :prompt => "prompt") }
  let(:run)      { FactoryGirl.create(:run) }
  let(:answer)   { FactoryGirl.create(:or_answer, :question => question, :run => run) }
  let(:endpoint) { "http://foo.bar.fake/baz" }

  describe "#update" do
    describe "with a run initiated from remote portlal" do
      let(:run)  {
        FactoryGirl.create(
          :run,
          :remote_endpoint => endpoint
        )
      }
      describe "with valid params" do
        let(:new_answer) { "this answer has been changed "}
        it "should update the answer" do
          post "update", :id => answer.id, :embeddable_open_response_answer => {
            :answer_text => new_answer
          }
          answer.reload
          answer.answer_text.should == new_answer
        end
        it "should fire off a web request to update the portal" do
          post "update", :id => answer.id, :embeddable_open_response_answer => {
            :answer_text => new_answer
          }
          assert_requested :post, endpoint
        end
      end
    end
  end

  describe "with no endpoint defined (not requested from portal)" do
    describe "with valid params" do
        let(:new_answer) { "this answer has been changed "}
        it "should update the answer" do
          post "update", :id => answer.id, :embeddable_open_response_answer => {
            :answer_text => new_answer
          }
          answer.reload
          answer.answer_text.should == new_answer
        end
        it "shouldn't fire a web request to update the portal" do
          post "update", :id => answer.id, :embeddable_open_response_answer => {
            :answer_text => new_answer
          }
          assert_not_requested :post, endpoint
        end
      end
  end
end