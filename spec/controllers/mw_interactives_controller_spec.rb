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
    context 'and an InteractivePage ID is provided' do
      describe 'new' do
        it 'automatically creates a new interactive' do
          activity
          starting_count = MwInteractive.count()
          join_count = InteractiveItem.count()
          get :new, :page_id => page.id

          expect(MwInteractive.count()).to equal starting_count + 1
          expect(InteractiveItem.count()).to equal join_count + 1
        end

        it 'redirects the submitter back to the page edit page' do
          activity
          get :new, :page_id => page.id
          new_id = MwInteractive.last().id
          expect(response).to redirect_to(edit_activity_page_path(activity, page, :edit_mw_int => new_id))
        end
      end

      describe 'create' do
        it 'creates an empty MW Interactive' do
          activity
          starting_count = MwInteractive.count()
          join_count = InteractiveItem.count()
          post :create, :page_id => page.id

          expect(MwInteractive.count()).to equal starting_count + 1
          expect(InteractiveItem.count()).to equal join_count + 1
        end

        it 'redirects the submitter to the page edit page' do
          activity
          post :create, :page_id => page.id
          new_id = MwInteractive.last().id
          expect(response).to redirect_to(edit_activity_page_path(activity, page, :edit_mw_int => new_id))
        end
      end
    end

    context 'when editing an existing MW Interactive' do
      describe 'edit' do
        it 'shows a form with values of the MW Interactive filled in' do
          get :edit, :id => int.id

          expect(response.body).to match /<form[^>]+action="\/mw_interactives\/#{int.id}"[^<]+method="post"[^<]*>/
          expect(response.body).to match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          expect(response.body).to match /<input[^<]+id="mw_interactive_name"[^<]+name="mw_interactive\[name\]"[^<]+type="text"[^>]+value="#{int.name}"[^<]*\/>/
          expect(response.body).to match /<input[^<]+id="mw_interactive_url"[^<]+name="mw_interactive\[url\]"[^<]+type="text"[^>]+value="#{int.url}"[^<]*\/>/
          expect(response.body).to match /<input[^<]+id="mw_interactive_native_width"[^<]+name="mw_interactive\[native_width\]"[^<]+type="text"[^<]+value="#{int.native_width}"[^<]*\/>/
          expect(response.body).to match /<input[^<]+id="mw_interactive_native_height"[^<]+name="mw_interactive\[native_height\]"[^<]+type="text"[^<]+value="#{int.native_height}"[^<]*\/>/
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

        it 'returns to the edit page with a message indicating success' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
          expect(flash[:notice]).to eq('Your iframe interactive was updated.')
        end

        it 'returns to the edit page with an error on failure' do
          new_values_hash = { :native_width => 'Ha!' }
          post :update, :id => int.id, :page_id => page.id, :mw_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
          expect(flash[:warning]).to eq('There was a problem updating your iframe interactive.')
        end
      end

      describe 'destroy' do
        it 'removes the requested MW Interactive from the database and page and redirects to the page edit page' do
          activity
          int
          InteractiveItem.create!(:interactive_page => page, :interactive => int)
          interactive_count = MwInteractive.count()
          page.reload
          page_count = page.interactives.length

          post :destroy, :id => int.id, :page_id => page.id

          expect(response).to redirect_to(edit_activity_page_path(activity, page))
          expect(MwInteractive.count()).to eq(interactive_count - 1)
          page.reload
          expect(page.interactives.length).to eq(page_count - 1)
          expect(flash[:notice]).to eq('Your Mw interactive was deleted.')
        end
      end
    end
  end
end
