require 'spec_helper'

describe MwInteractivesController do
  render_views

  describe 'index' do
    it 'returns a list of available MW Interactives' do
      pending 'Future feature'
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

  context 'when the logged-in user is an author' do
    # Authorization is tested in spec/models/user_spec.rb
    context 'and an InteractivePage ID is provided' do
      before do
        @act = LightweightActivity.create!(:name => "Test activity")
        @page = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '')
      end

      describe 'new' do
        it 'automatically creates a new interactive' do
          starting_count = MwInteractive.count()
          join_count = InteractiveItem.count()
          get :new, :page_id => @page.id

          MwInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter back to the page edit page' do
          get :new, :page_id => @page.id
          new_id = MwInteractive.last().id
          response.should redirect_to(edit_activity_page_path(@act, @page, :edit_int => new_id))
        end
      end

      describe 'create' do
        it 'creates an empty MW Interactive' do
          starting_count = MwInteractive.count()
          join_count = InteractiveItem.count()
          post :create, :page_id => @page.id

          MwInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter to the page edit page' do
          post :create, :page_id => @page.id
          new_id = MwInteractive.last().id
          response.should redirect_to(edit_activity_page_path(@act, @page, :edit_int => new_id))
        end
      end
    end

    context 'when editing an existing MW Interactive' do
      before do
        @act = LightweightActivity.create!()
        @page = InteractivePage.create!(:name => 'Page with interactive', :lightweight_activity => @act)
        @int = MwInteractive.create!(:name => 'Test Interactive', :url => 'http://concord.org')
      end

      describe 'edit' do
        it 'shows a form with values of the MW Interactive filled in' do
          get :edit, :id => @int.id

          response.body.should match /<form[^>]+action="\/mw_interactives\/#{@int.id}"[^<]+method="post"[^<]*>/
          response.body.should match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          response.body.should match /<input[^<]+id="mw_interactive_name"[^<]+name="mw_interactive\[name\]"[^<]+type="text"[^>]+value="#{@int.name}"[^<]*\/>/
          response.body.should match /<input[^<]+id="mw_interactive_url"[^<]+name="mw_interactive\[url\]"[^<]+type="text"[^>]+value="#{@int.url}"[^<]*\/>/
          response.body.should match /<input[^<]+id="mw_interactive_native_width"[^<]+name="mw_interactive\[native_width\]"[^<]+type="text"[^<]+value="#{@int.native_width}"[^<]*\/>/
          response.body.should match /<input[^<]+id="mw_interactive_native_height"[^<]+name="mw_interactive\[native_height\]"[^<]+type="text"[^<]+value="#{@int.native_height}"[^<]*\/>/
        end

        it 'responds to js-format requests with JSON' do
          get :edit, :id => @int.id, :page_id => @page.id, :format => 'js'

          response.headers['Content-Type'].should match /text\/json/
          response.body.should match /<form[^>]+action=\\"\/pages\/#{@page.id}\/mw_interactives\/#{@int.id}\\"[^<]+method=\\"post\\"[^<]*>/
        end
      end

      describe 'update' do
        it 'replaces the values of the MW Interactive to match submitted values' do
          new_values_hash = { :name => 'Edited name', :url => 'http://lab.concord.org' }
          post :update, :id => @int.id, :mw_interactive => new_values_hash

          mw_int = MwInteractive.find(@int.id)
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
          @act = LightweightActivity.create!()
          @page = InteractivePage.create!(:name => 'Page with interactive', :lightweight_activity => @act)
          InteractiveItem.create!(:interactive_page => @page, :interactive => @int)
          interactive_count = MwInteractive.count()
          page_count = @page.interactives.length

          post :destroy, :id => @int.id, :page_id => @page.id

          response.should redirect_to(edit_activity_page_path(@act, @page))
          MwInteractive.count().should == interactive_count - 1
          @page.reload
          @page.interactives.length.should == page_count - 1
          flash[:notice].should == 'Your interactive was deleted.'
        end
      end
    end
  end
end
