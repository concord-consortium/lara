require 'spec_helper'

describe MwInteractivesController do
  it_behaves_like "interactives controller" do
    let(:interactive_label) { :mw_interactive }
  end

  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:mw_interactive, :name => 'Test Interactive') }

  before(:each) {
    page.add_embeddable(int)
  }

  describe 'edit' do
    it 'shows a form which renders the React-based MW Interactive editor' do
      get :edit, :id => int.id
      expect(response.body).to match /LARA.PageItemAuthoring.renderMWInteractiveAuthoring/
    end

    it 'responds to js-format requests with JSON' do
      page
      get :edit, :id => int.id, :page_id => page.id, :format => 'js'

      expect(response.headers['Content-Type']).to match /text\/json/
      value_hash = JSON.parse(response.body)
      expect(value_hash['html']).to match %r[<form[^>]+action=\"\/mw_interactives\/#{int.id}\"[^<]+method=\"post]
    end
  end

  # TODO: Try reinstating this after upgrading the dynamic_form gem (will require Ruby 2.7).
  describe 'update', :skip do
    it 'raises an error when update fails' do
      expect {
        new_values_hash = { :native_width => 'Ha!' }
        post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
