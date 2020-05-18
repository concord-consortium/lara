require 'spec_helper'

describe ManagedInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:library_interactive) { FactoryGirl.create(:library_interactive, :name => 'Test Library Interactive', :base_url => 'http://concord.org/') }
  let (:int) { FactoryGirl.create(:managed_interactive, :name => 'Test Managed Interactive', :url_fragment => '/interactive') }

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
    context 'when editing an existing Managed Interactive' do
      describe 'edit' do
        it 'shows a form with values of the Managed Interactive filled in' do
          get :edit, :id => int.id
          expect(response).to be_successful
        end

        it 'responds to js-format requests with JSON' do
          page
          get :edit, :id => int.id, :page_id => page.id, :format => 'js'

          expect(response.headers['Content-Type']).to match /text\/json/
          value_hash = JSON.parse(response.body)
          expect(value_hash['html']).to match %r[<form[^>]+action=\"/pages\/#{page.id}\/managed_interactives\/#{int.id}\"[^<]+method=\"post]
        end
      end

      describe 'update' do
        it 'replaces the values of the Managed Interactive to match submitted values' do
          new_values_hash = { :name => 'Edited name', :url_fragment => '/foo' }
          post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash

          managed_int = ManagedInteractive.find(int.id)
          expect(managed_int.name).to eq(new_values_hash[:name])
          expect(managed_int.url_fragment).to eq(new_values_hash[:url_fragment])
        end

        it 'returns to the edit page with a message indicating success' do
          new_values_hash = { :name => 'Edited name', :url_fragment => '/foo' }
          post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
          expect(flash[:notice]).to eq('Your managed interactive was updated.')
        end

        it 'returns to the edit page with an error on failure' do
          new_values_hash = { :custom_native_width => 'Ha!' }
          post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
          expect(flash[:warning]).to eq('There was a problem updating your managed interactive.')
        end
      end
    end
  end
end
