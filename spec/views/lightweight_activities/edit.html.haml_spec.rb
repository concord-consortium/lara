require 'spec_helper'


# Chrome tip: open inspector, right-click on your HTML, copy Xpath...
def official_checkox
  '//*[@id="lightweight_activity_is_official"]'
end


describe "lightweight_activities/edit" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1) }
  let(:user)      { stub_model(User, :is_admin => false)      }

  before(:each) do
    view.stub!(:current_user).and_return(user)
    assign(:activity, activity)
  end

  describe "the form" do
    describe "is_official checkbox" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the checkbox" do
          render
          rendered.should have_xpath official_checkox
        end
      end

      context "when the current user is not an admin" do
        let (:user) { stub_model(User, :is_admin => false)}
        it "should show the checkbox" do
          render
          rendered.should_not have_xpath official_checkox
        end
      end
    end
  end
end
