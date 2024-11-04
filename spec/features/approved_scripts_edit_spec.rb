require "spec_helper"
require "uri"

feature "Admin edits approved scripts" do
  let(:user) { FactoryGirl.create(:admin) }
  let(:approved_script) { FactoryGirl.create(:approved_script) }
  let(:url) { edit_approved_script_path(approved_script) }

  scenario "and loads the form" do

    login_as user, scope: :user
    visit url

    expect(page).to have_field("Json url", with: approved_script[:json_url])
    expect(page).to have_field("Name", with: approved_script[:name])
    expect(page).to have_field("Label", with: approved_script[:label])
    expect(page).to have_field("Url", with: approved_script[:url])
    expect(page).to have_field("Version", with: approved_script[:version])
    expect(page).to have_field("Description", with: approved_script[:description])
  end
end
