require 'spec_helper'

describe VideoInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:video_interactive, :poster_url => 'http://example.com/poster.png') }

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
          starting_count = VideoInteractive.count()
          join_count = InteractiveItem.count()
          get :new, :page_id => page.id

          VideoInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter back to the page edit page' do
          activity
          get :new, :page_id => page.id
          new_id = VideoInteractive.last().id
          response.should redirect_to(edit_activity_page_path(activity, page, :edit_vid_int => new_id))
        end
      end

      describe 'create' do
        it 'creates an empty MW Interactive' do
          activity
          starting_count = VideoInteractive.count()
          join_count = InteractiveItem.count()
          post :create, :page_id => page.id

          VideoInteractive.count().should equal starting_count + 1
          InteractiveItem.count().should equal join_count + 1
        end

        it 'redirects the submitter to the page edit page' do
          activity
          post :create, :page_id => page.id
          new_id = VideoInteractive.last().id
          response.should redirect_to(edit_activity_page_path(activity, page, :edit_vid_int => new_id))
        end
      end
    end

    context 'when editing an existing Video Interactive' do
      describe 'edit' do
        it 'shows a form with values of the Video Interactive filled in' do
          get :edit, :id => int.id

          response.body.should match /<form[^>]+action="\/video_interactives\/#{int.id}"[^<]+method="post"[^<]*>/
          response.body.should match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          response.body.should match /<input[^<]+id="video_interactive_poster_url"[^<]+name="video_interactive\[poster_url\]"[^<]+type="text"[^>]+value="#{int.poster_url}"[^<]*\/>/
          response.body.should match /<textarea[^<]+id="video_interactive_caption"[^<]+name="video_interactive\[caption\]"[^<]*>#{int.caption}/
          response.body.should match /<textarea[^<]+id="video_interactive_credit"[^<]+name="video_interactive\[credit\]"[^<]*>#{int.credit}/
        end

        it 'responds to js-format requests with JSON' do
          page
          get :edit, :id => int.id, :page_id => page.id, :format => 'js'

          response.headers['Content-Type'].should match /text\/json/
          value_hash = JSON.parse(response.body)
          value_hash['html'].should match %r[<form[^>]+action=\"/pages\/#{page.id}\/video_interactives\/#{int.id}\"[^<]+method=\"post]
        end
      end

      describe 'update' do
        it 'replaces the values of the Video Interactive to match submitted values' do
          new_values_hash = { :caption => 'I made this up', :poster_url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :page_id => page.id, :video_interactive => new_values_hash

          int.reload
          int.caption.should == new_values_hash[:caption]
          int.poster_url.should == new_values_hash[:poster_url]
        end

        it 'returns to the edit page with a message indicating success' do
          new_values_hash = { :caption => 'I made this up', :poster_url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :page_id => page.id, :video_interactive => new_values_hash
          response.should redirect_to(edit_activity_page_path(activity, page))
          flash[:notice].should == 'Your video interactive was updated.'
        end

        # it 'returns to the edit page with an error on failure' do
        #   pending "Trying to get an failure and not a 500 error isn't working."
        #   new_values_hash = { :bogus => 'Ha!' }
        #   post :update, :id => int.id, :video_interactive => new_values_hash
        #   response.should redirect_to(edit_video_interactive_path(int))
        #   flash[:warning].should == 'There was a problem updating your Video Interactive'
        # end
      end

      describe 'destroy' do
        it 'removes the requested Video Interactive from the database and page and redirects to the page edit page' do
          activity
          int
          InteractiveItem.create!(:interactive_page => page, :interactive => int)
          interactive_count = VideoInteractive.count()
          page.reload
          page_count = page.interactives.length

          post :destroy, :id => int.id, :page_id => page.id

          response.should redirect_to(edit_activity_page_path(activity, page))
          VideoInteractive.count().should == interactive_count - 1
          page.reload
          page.interactives.length.should == page_count - 1
          flash[:notice].should == 'Your Video interactive was deleted.'
        end
      end
    end
  end
end
