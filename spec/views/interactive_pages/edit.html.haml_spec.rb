require 'spec_helper'

describe "interactive_pages/edit" do
  let(:activity)  { stub_model(LightweightActivity, :id => 1, :name => 'Stub activity')}

  let (:page) do
    p = FactoryGirl.create(:page, :name => "fake page", :lightweight_activity => activity, :embeddable_display_mode => 'carousel')
    allow(p).to receive_messages(:last? => true)
    [3,1,2].each do |i|
      embed = FactoryGirl.create(:xhtml, :name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end

  let (:page1) { page }
  let (:page2) { FactoryGirl.create(:page, :name => 'Another fake page', :lightweight_activity => activity ) }

  before :each do
    assign(:activity, activity)
    assign(:page, page)
    assign(:all_pages, [page])
  end

  # it 'saves first edits made in the WYSIWYG editor', :js => true, :slow => true do
  #   pending 'This is an issue with the editor, not this application'
  #   page.show_introduction = 1
  #   page.show_interactive = 0
  #   page.save
  # 
  #   visit new_user_session_path
  #   fill_in "Email", :with => @user.email
  #   fill_in "Password", :with => @user.password
  #   click_button "Sign in"
  #   visit edit_activity_page_path(act, page1)
  # 
  #   find('#interactive_page_text_trigger').click
  #   find('#interactive_page_text')
  #   within_frame('interactive_page_text-wysiwyg-iframe') do
  #     page.should have_content(page1.text)
  #     # TODO: How can I put content in the WYSIWYG editor?
  #   end
  #   find('.wysiwyg li.html').click()
  #   fill_in 'interactive_page[text]', :with => 'This is edited text'
  #   find('.editable button[type="submit"]').click
  #   page.should have_content('This is edited text')
  # end

  it 'has options to preview the page or add another page' do
    render
    expect(rendered).to match /<option[^>]+value="\/activities\/#{activity.id}\/pages\/#{page.id}\/preview"[^>]*>[\s]*LARA Runtime[\s]*<\/option>/
    # Used to check for a link back to the activity, but that's in the breadcrumbs now and not part of this view
    # rendered.should match /<a[^>]+href="\/activities\/#{activity.id}\/edit"[^>]*>[\s]*#{activity.name}[\s]*<\/a>/
    # rendered.should match /<a[^>]+href="\/activities\/#{activity.id}\/pages\/new"[^>]*>[\s]*Add another page to #{activity.name}[\s]*<\/a>/
    expect(rendered).to match /<a[^>]+href="\/activities\/#{activity.id}\/pages\/new"[^>]*>/
    # Same here - this link has gone to breadcrumbs
    # rendered.should match /<a[^>]+href="\/activities"[^<]*>[\s]*All Activities[\s]*<\/a>/
  end

  it 'has links for adding Embeddables to the page' do
    render
    expect(rendered).to match /<form[^>]+action="\/activities\/#{activity.id}\/pages\/#{page.id}\/add_embeddable"[^<]*>/
    expect(rendered).to match /<select[^>]+name="embeddable_type"[^>]*>/
  end

  it 'shows navigation links' do
    page1
    page2
    assign(:page, page1)
    assign(:all_pages, [page1, page2])
    render

    expect(rendered).to match /<a[^>]+class='next'[^>]+href='\/activities\/#{activity.id}\/pages\/#{page2.id}\/edit'[^>]*>[\s]*&nbsp;[\s]*<\/a>/
  end
end
