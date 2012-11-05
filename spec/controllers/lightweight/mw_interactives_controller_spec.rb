require 'spec_helper'

describe Lightweight::MwInteractivesController do
  render_views
  before do
    # work around bug in routing testing
    @routes = Lightweight::Engine.routes
  end

  describe 'index' do
    it 'returns a list of available MW Interactives' do
      pending 'Not working this yet'
    end
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

  context 'when the logged-in user is an ordinary user' do
    describe 'interactives' do
      it 'are not editable' do
        pending 'we are not yet ready for this'
      end
    end
  end

  context 'when the logged-in user is an author' do
    context 'and an InteractivePage ID is provided' do
      before do
        @page = Lightweight::InteractivePage.create!()
      end

      describe 'new' do
        it 'automatically creates a new interactive' do
          starting_count = Lightweight::MwInteractive.count()
          join_count = Lightweight::InteractiveItem.count()
          get :new, :page_id => @page.id

          Lightweight::MwInteractive.count().should equal starting_count + 1
          Lightweight::InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter to the edit page' do
          get :new
          response.should redirect_to("/lightweight/mw_interactives/#{assigns(:interactive).id}/edit")
        end
      end

      describe 'create' do
        it 'creates an empty MW Interactive' do
          starting_count = Lightweight::MwInteractive.count()
          join_count = Lightweight::InteractiveItem.count()
          post :create, :page_id => @page.id

          Lightweight::MwInteractive.count().should equal starting_count + 1
          Lightweight::InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter to the edit page' do
          post :create, :page_id => @page.id
          response.should redirect_to("/lightweight/pages/#{@page.id}/mw_interactives/#{assigns(:interactive).id}/edit")
        end
      end
    end

    context 'when editing an existing MW Interactive' do
      before do
        @int = Lightweight::MwInteractive.create!(:name => 'Test Interactive', :url => 'http://concord.org')
      end

      describe 'edit' do
        it 'shows a form with values of the MW Interactive filled in' do
          get :edit, :id => @int.id

          response.body.should match /<form[^>]+action="\/lightweight\/mw_interactives\/#{@int.id}"[^<]+method="post"[^<]*>/
          response.body.should match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          response.body.should match /<input[^<]+id="mw_interactive_width"[^<]+name="mw_interactive\[width\]"[^<]+type="text"[^<]+value="#{@int.width}"[^<]*\/>/
          response.body.should match /<input[^<]+id="mw_interactive_name"[^<]+name="mw_interactive\[name\]"[^<]+type="text"[^>]+value="#{@int.name}"[^<]*\/>/
          response.body.should match /<input[^<]+id="mw_interactive_url"[^<]+name="mw_interactive\[url\]"[^<]+type="text"[^>]+value="#{@int.url}"[^<]*\/>/
        end

        it 'has a link to go back to the page if one exists' do
          @act = Lightweight::LightweightActivity.create!()
          @page = Lightweight::InteractivePage.create!(:name => 'Page with interactive', :lightweight_activity => @act)
          Lightweight::InteractiveItem.create!(:interactive_page => @page, :interactive => @int)

          get :edit, :page_id => @page.id, :id => @int.id
          response.body.should match /<a[^<]+href="\/lightweight\/activities\/#{@act.id}\/pages\/#{@page.id}\/edit"[^<]*>[\s]*Go back to #{@page.name}[\s]*<\/a>/
        end
      end

      describe 'update' do
        it 'replaces the values of the MW Interactive to match submitted values' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => @int.id, :mw_interactive => new_values_hash

          mw_int = Lightweight::MwInteractive.find(@int.id)
          mw_int.name.should == new_values_hash[:name]
          mw_int.url.should == new_values_hash[:url]
        end

        it 'returns to the edit page with a message indicating success' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => @int.id, :mw_interactive => new_values_hash
          response.should redirect_to(edit_mw_interactive_path(@int))
          flash[:notice].should == 'Your MW Interactive was updated'
        end

        it 'returns to the edit page with an error on failure' do
          new_values_hash = { :width => nil }
          post :update, :id => @int.id, :mw_interactive => new_values_hash
          response.should redirect_to(edit_mw_interactive_path(@int))
          flash[:warning].should == 'There was a problem updating your MW Interactive'
        end
      end

      describe 'destroy' do
        it 'removes the requested MW Interactive from the database and page and redirects to the page edit page' do
          @act = Lightweight::LightweightActivity.create!()
          @page = Lightweight::InteractivePage.create!(:name => 'Page with interactive', :lightweight_activity => @act)
          Lightweight::InteractiveItem.create!(:interactive_page => @page, :interactive => @int)
          interactive_count = Lightweight::MwInteractive.count()
          page_count = @page.interactives.length

          post :destroy, :id => @int.id, :page_id => @page.id

          response.should redirect_to(edit_activity_page_path(@act, @page))
          Lightweight::MwInteractive.count().should == interactive_count - 1
          @page.reload
          @page.interactives.length.should == page_count - 1
          flash[:notice].should == 'Your interactive was deleted.'
        end
      end
    end
  end
end
