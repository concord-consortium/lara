require 'spec_helper'

describe MwInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:mw_interactive, :name => 'Test Interactive', :url => 'http://concord.org') }

  describe 'index' do
    # it 'returns a list of available MW Interactives' do
    #   pending 'Future feature'
    # end
  end

  describe 'show' do
    it 'is not routable' do
      begin
        get :show, :id => 'foo'
        throw 'should not have been able to route to show'
      rescue
      end
    end
  end

  context 'when the logged-in user is an author' do
    # Authorization is tested in spec/models/user_spec.rb
    context 'when editing an existing MW Interactive' do
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
          expect(value_hash['html']).to match %r[<form[^>]+action=\"/pages\/#{page.id}\/mw_interactives\/#{int.id}\"[^<]+method=\"post]
        end
      end

      describe 'update' do
        it 'replaces the values of the MW Interactive to match submitted values' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash

          mw_int = MwInteractive.find(int.id)
          expect(mw_int.name).to eq(new_values_hash[:name])
          expect(mw_int.url).to eq(new_values_hash[:url])
        end

        it 'returns to the edit page when there are no errors' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
        end

        it 'raises an error when update fails' do
          expect {
            new_values_hash = { :native_width => 'Ha!' }
            post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash
          }.to raise_error ActiveRecord::RecordInvalid
        end
      end
    end
  end
end
