require 'spec_helper'

describe VideoInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:video_interactive, :poster_url => 'http://example.com/poster.png') }

  before(:each) {
    page.add_embeddable(int)
  }

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
    context 'when editing an existing Video Interactive' do
      describe 'edit' do
        it 'shows a form with values of the Video Interactive filled in' do
          get :edit, :id => int.id

          expect(response.body).to match /<form[^>]+action="\/video_interactives\/#{int.id}"[^<]+method="post"[^<]*>/
          expect(response.body).to match /<input[^<]+name="_method"[^<]+type="hidden"[^<]+value="put"[^<]+\/>/

          expect(response.body).to match /<input[^<]+id="video_interactive_poster_url"[^<]+name="video_interactive\[poster_url\]"[^<]+type="text"[^>]+value="#{int.poster_url}"[^<]*\/>/
          expect(response.body).to match /<textarea[^<]+id="video_interactive_caption"[^<]+name="video_interactive\[caption\]"[^<]*>#{int.caption}/
          expect(response.body).to match /<textarea[^<]+id="video_interactive_credit"[^<]+name="video_interactive\[credit\]"[^<]*>#{int.credit}/
        end

        it 'responds to js-format requests with JSON' do
          page
          get :edit, :id => int.id, :page_id => page.id, :format => 'js'

          expect(response.headers['Content-Type']).to match /text\/json/
          value_hash = JSON.parse(response.body)
          expect(value_hash['html']).to match %r[<form[^>]+action=\"\/video_interactives\/#{int.id}\"[^<]+method=\"post]
        end
      end

      describe 'update' do
        it 'replaces the values of the Video Interactive to match submitted values' do
          new_values_hash = { :caption => 'I made this up', :poster_url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :page_id => page.id, :video_interactive => new_values_hash

          int.reload
          expect(int.caption).to eq(new_values_hash[:caption])
          expect(int.poster_url).to eq(new_values_hash[:poster_url])
        end

        it 'returns to the edit page' do
          new_values_hash = { :caption => 'I made this up', :poster_url => 'http://mw.concord.org/modeler/_assets/img/mw.png' }
          post :update, :id => int.id, :page_id => page.id, :video_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
        end

        # it 'returns to the edit page with an error on failure' do
        #   pending "Trying to get an failure and not a 500 error isn't working."
        #   new_values_hash = { :bogus => 'Ha!' }
        #   post :update, :id => int.id, :video_interactive => new_values_hash
        #   response.should redirect_to(edit_video_interactive_path(int))
        #   flash[:warning].should == 'There was a problem updating your Video Interactive'
        # end
      end
    end
  end
end
