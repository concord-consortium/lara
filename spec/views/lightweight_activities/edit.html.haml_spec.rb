require 'spec_helper'

# Chrome tip: open inspector, right-click on your HTML, copy Xpath... ## <= this is gold.
def official_checkox
  '//*[@id="lightweight_activity_is_official"]'
end


describe "lightweight_activities/edit" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1, :name => 'Activity name') }
  let(:user)      { stub_model(User, :is_admin => false)      }

  before(:each) do
    view.stub!(:current_user).and_return(user)
    assign(:activity, activity)
  end

  describe "the form" do
    let (:user) { stub_model(User, :is_admin => true)}

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
        it "should not show the checkbox" do
          render
          rendered.should_not have_xpath official_checkox
        end
      end
    end

    it 'should show the current activity name' do
      render
      rendered.should match /<input[^>]+id="lightweight_activity_name"[^>]+name="lightweight_activity\[name\]"[^>]+type="text"[^<]+value="#{activity.name}"[^<]*\/>/
    end

    it 'should show the current activity description' do
      render
      rendered.should match /<span[^>]+class="editable"[^>]+data-name="lightweight_activity\[description\]"[^<]*>/
    end

    it 'should show related text' do
      render
      rendered.should match /<span[^>]+class="editable"[^>]+data-name="lightweight_activity\[related\]"[^<]*>/
    end

    # TODO: This is breadcrumbs and doesn't get tested in this view
    # it 'should link to the list of activities' do
    #   render
    #   rendered.should match /<a[^>]+href="\/activities"[^<]*>[\s]*All Activities[\s]*<\/a>/
    # end

    it 'should provide a select menu of themes' do
      render
      rendered.should have_css('select#lightweight_activity_theme_id')
      rendered.should have_css('select#lightweight_activity_theme_id option')
    end

    it 'should provide a select menu of projects' do
      render
      rendered.should have_css('select#lightweight_activity_project_id')
      rendered.should have_css('select#lightweight_activity_project_id option')
    end

    it 'should provide a link to add new pages' do
      render
      rendered.should match /<a[^>]+href="\/activities\/#{activity.id}\/pages\/new"/
    end

    it 'should provide in-place editing of description and sidebar'  do
      pending "Rewrite for view specs"
      act
      visit new_user_session_path
      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
      visit edit_activity_path(act)

      find("#lightweight_activity_description_trigger").click
      page.should have_selector('#lightweight_activity_description-wysiwyg-iframe')
    end
  end
end
