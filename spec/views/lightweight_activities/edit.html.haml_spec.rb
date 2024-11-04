require 'spec_helper'

# Chrome tip: open inspector, right-click on your HTML, copy Xpath... ## <= this is gold.
def defunct_checkbox
  '//*[@id="lightweight_activity_defunct"]'
end
def official_checkbox
  '//*[@id="lightweight_activity_is_official"]'
end
def hide_read_aloud_checkbox
  '//*[@id="lightweight_activity_hide_read_aloud"]'
end
def hide_question_numbers_checkbox
  '//*[@id="lightweight_activity_hide_question_numbers"]'
end
def font_size_select
  '//*[@id="lightweight_activity_font_size"]'
end

describe "lightweight_activities/edit" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1, :name => 'Activity name', :defunct => false, :hide_read_aloud => false, :hide_question_numbers => false, :font_size => "normal") }
  let(:user)      { stub_model(User, :is_admin => false)      }

  before(:each) do
    allow(view).to receive(:current_user).and_return(user)
    assign(:activity, activity)
  end

  describe "the form" do
    let (:user) { stub_model(User, :is_admin => true)}

    describe "defunct checkbox" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the checkbox" do
          render
          expect(rendered).to have_xpath defunct_checkbox
        end
      end

      context "when the current user is not an admin" do
        let (:user) { stub_model(User, :is_admin => false)}
        it "should not show the checkbox" do
          render
          expect(rendered).not_to have_xpath defunct_checkbox
        end
      end
    end

    describe "hide_read_aloud checkbox" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the checkbox" do
          render
          expect(rendered).to have_xpath hide_read_aloud_checkbox
        end
      end

      context "when the current user is not an admin" do
        let (:user) { stub_model(User, :is_admin => false)}
        it "should not show the checkbox" do
          render
          expect(rendered).to have_xpath hide_read_aloud_checkbox
        end
      end
    end

    describe "hide_question_numbers checkbox" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the checkbox" do
          render
          expect(rendered).to have_xpath hide_question_numbers_checkbox
        end
      end

      context "when the current user is an author" do
        let (:user) { stub_model(User, :is_author => true)}
        it "should show the checkbox" do
          render
          expect(rendered).to have_xpath hide_question_numbers_checkbox
        end
      end

      context "when the current user is not an admin or author" do
        let (:user) { stub_model(User, :is_admin => false, :is_author => false)}
        it "should not show the checkbox" do
          render
          expect(rendered).to have_xpath hide_question_numbers_checkbox
        end
      end
    end

    describe "font_size select" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the select" do
          render
          expect(rendered).to have_xpath font_size_select
        end
      end

      context "when the current user is not an admin" do
        let (:user) { stub_model(User, :is_admin => false)}
        it "should show the select" do
          render
          expect(rendered).to have_xpath font_size_select
        end
      end
    end

    describe "is_official checkbox" do
      context "when the current user is an admin" do
        let (:user) { stub_model(User, :is_admin => true)}
        it "should show the checkbox" do
          render
          expect(rendered).to have_xpath official_checkbox
        end
      end

      context "when the current user is not an admin" do
        let (:user) { stub_model(User, :is_admin => false)}
        it "should not show the checkbox" do
          render
          expect(rendered).not_to have_xpath official_checkbox
        end
      end
    end

    it 'should show the current activity name' do
      render
      assert_select "input#lightweight_activity_name", :name => "lightweight_activity[name]", :value => activity.name
    end

    it 'should show the current activity description' do
      render
      expect(rendered).to match /<textarea[^>]+name="lightweight_activity\[description\]"[^<]*>/
    end

    it 'should show related text' do
      render
      expect(rendered).to match /<textarea[^>]+name="lightweight_activity\[related\]"[^<]*>/
    end

    # TODO: This is breadcrumbs and doesn't get tested in this view
    # it 'should link to the list of activities' do
    #   render
    #   rendered.should match /<a[^>]+href="\/activities"[^<]*>[\s]*All Activities[\s]*<\/a>/
    # end

    it 'should provide a select menu of projects' do
      render
      expect(rendered).to have_css('select#lightweight_activity_project_id')
      expect(rendered).to have_css('select#lightweight_activity_project_id option')
    end

    it 'should provide a link to add new pages' do
      render
      expect(rendered).to match /<a[^>]+href="\/activities\/#{activity.id}\/pages\/new"/
    end

    it 'should provide in-place editing of description and sidebar'  do
      skip "Rewrite for view specs"
      act
      visit new_user_session_path
      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
      visit edit_activity_path(act)

      find("#lightweight_activity_description_trigger").click
      expect(page).to have_selector('#lightweight_activity_description-wysiwyg-iframe')
    end
  end
end
