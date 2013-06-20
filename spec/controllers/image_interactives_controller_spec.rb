require 'spec_helper'

describe ImageInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:image_interactive, :url => 'http://mw.concord.org/modeler/_assets/img/cc-logo-1.png') }

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
          starting_count = ImageInteractive.count()
          join_count = InteractiveItem.count()
          get :new, :page_id => page.id

          ImageInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter back to the page edit page' do
          activity
          get :new, :page_id => page.id
          new_id = ImageInteractive.last().id
          response.should redirect_to(edit_activity_page_path(activity, page, :edit_img_int => new_id))
        end
      end

      describe 'create' do
        it 'creates an empty MW Interactive' do
          activity
          starting_count = ImageInteractive.count()
          join_count = InteractiveItem.count()
          post :create, :page_id => page.id

          ImageInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter to the page edit page' do
          activity
          post :create, :page_id => page.id
          new_id = ImageInteractive.last().id
          response.should redirect_to(edit_activity_page_path(activity, page, :edit_img_int => new_id))
        end
      end
    end

    context 'when editing an existing Image Interactive' do
      describe 'edit' do
        it 'shows a form with values of the Image Interactive filled in' do
          get :edit, :id => int.id

          response.body.should match /<form[^>]+action="\/image_interactives\/#{int.id}"[^<]+method="post"[^<]*>/
          response.body.should match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          response.body.should match /<input[^<]+id="image_interactive_url"[^<]+name="image_interactive\[url\]"[^<]+type="text"[^>]+value="#{int.url}"[^<]*\/>/
          # TODO: These may be textareas
          response.body.should match /<textarea[^<]+id="image_interactive_caption"[^<]+name="image_interactive\[caption\]"[^<]*>#{int.caption}/
          response.body.should match /<textarea[^<]+id="image_interactive_credit"[^<]+name="image_interactive\[credit\]"[^<]*>#{int.credit}/
        end

        it 'responds to js-format requests with JSON' do
          page
          get :edit, :id => int.id, :page_id => page.id, :format => 'js'

          response.headers['Content-Type'].should match /text\/json/
          response.body.should match /<form[^>]+action=\\"\/pages\/#{page.id}\/image_interactives\/#{int.id}\\"[^<]+method=\\"post\\"[^<]*>/
        end
      end

      describe 'update' do
        it 'replaces the values of the Image Interactive to match submitted values' do
          new_values_hash = { :caption => 'I made this up', :url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :image_interactive => new_values_hash

          int.reload
          int.caption.should == new_values_hash[:caption]
          int.url.should == new_values_hash[:url]
        end

        it 'returns to the edit page with a message indicating success' do
          new_values_hash = { :caption => 'I made this up', :url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :image_interactive => new_values_hash
          response.should redirect_to(edit_image_interactive_path(int))
          flash[:notice].should == 'Your image was updated'
        end

        # it 'returns to the edit page with an error on failure' do
        #   pending "Trying to get an failure and not a 500 error isn't working."
        #   new_values_hash = { :bogus => 'Ha!' }
        #   post :update, :id => int.id, :image_interactive => new_values_hash
        #   response.should redirect_to(edit_image_interactive_path(int))
        #   flash[:warning].should == 'There was a problem updating your Image Interactive'
        # end
      end

      describe 'destroy' do
        it 'removes the requested Image Interactive from the database and page and redirects to the page edit page' do
          activity
          int
          InteractiveItem.create!(:interactive_page => page, :interactive => int)
          interactive_count = ImageInteractive.count()
          page.reload
          page_count = page.interactives.length

          post :destroy, :id => int.id, :page_id => page.id

          response.should redirect_to(edit_activity_page_path(activity, page))
          ImageInteractive.count().should == interactive_count - 1
          page.reload
          page.interactives.length.should == page_count - 1
          flash[:notice].should == 'Your image was deleted.'
        end
      end
    end
  end
end
