require 'spec_helper'

describe Lightweight::InteractivePagesController do
  render_views
  before do
    # work around bug in routing testing
    @routes = Lightweight::Engine.routes
  end

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => "activities/1/pages/3/2"}.should route_to(:controller => 'lightweight/interactive_pages', :action => 'show', :id => "3", :activity_id => "1", :offering_id => '2')
      {:get => "activities/1/pages/3"}.should route_to(:controller => 'lightweight/interactive_pages', :action => 'show', :id => "3", :activity_id => "1")
    end
  end

  describe 'show' do
    it 'does not route when id is not valid' do
      begin
        get :show, :id => 'foo'
        throw "Should not have been able to route with id='foo'"
      rescue ActionController::RoutingError
      end
    end

    it 'renders 404 when the activity does not exist' do
      begin
        get :show, :id => 34
      rescue ActionController::RoutingError
      rescue ActiveRecord::RecordNotFound
      end
    end

    it 'renders the page if it exists' do
      # setup
      # Mock the setup_portal_student method because we don't have a current_user method (it's provided by the session)
      @learner = mock_model(Portal::Learner, :valid? => true,:[]= => true, :save => true, :destroy=> false, :delete=>false)
      controller.stub(:setup_portal_student) { @learner }
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")

      # Add the offering - this can't be mocked because it's too close to the Activity
      offer = Portal::Offering.create!
      offer.runnable = act
      offer.save

      # set up page
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      interactive = Lightweight::MwInteractive.create!(:name => "MW model", :url => "http://google.com")
      page1.add_interactive(interactive)

      # Add embeddables
      or1 = Embeddable::OpenResponse.create!(:name => "Open Response 1", :prompt => "Why do you think this model is cool?")
      or2 = Embeddable::OpenResponse.create!(:name => "Open Response 2", :prompt => "What would you add to it?")

      mc1 = Embeddable::MultipleChoice.create!(:name => "Multiple choice 1", :prompt => "What color is chlorophyll?")
      Embeddable::MultipleChoiceChoice.create(:choice => 'Red', :multiple_choice => mc1)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Green', :multiple_choice => mc1)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Blue', :multiple_choice => mc1)

      mc2 = Embeddable::MultipleChoice.create!(:name => "Multiple choice 2", :prompt => "How many protons does Helium have?")
      Embeddable::MultipleChoiceChoice.create(:choice => '1', :multiple_choice => mc2)
      Embeddable::MultipleChoiceChoice.create(:choice => '2', :multiple_choice => mc2)
      Embeddable::MultipleChoiceChoice.create(:choice => '4', :multiple_choice => mc2)
      Embeddable::MultipleChoiceChoice.create(:choice => '7', :multiple_choice => mc2)

      xhtml1 = Embeddable::Xhtml.create!(:name => "Xhtml 1", :content => "This is some <strong>xhtml</strong> content!")

      page1.add_embeddable(mc1)
      page1.add_embeddable(or1)
      page1.add_embeddable(xhtml1)
      page1.add_embeddable(or2)
      page1.add_embeddable(mc2)

      # get the rendering
      get :show, :id => page1.id, :offering_id => offer.id

      # verify the page is as expected
      response.body.should match /<iframe[^>]*src=['"]http:\/\/google.com['"]/m
      response.body.should match /What color is chlorophyll\?/m
      response.body.should match /Why do you think this model is cool\?/m
      response.body.should match /What would you add to it\?/m
      response.body.should match /How many protons does Helium have\?/m
      response.body.should match /This is some <strong>xhtml<\/strong> content!/m
      response.body.should match /<form accept-charset="UTF-8" action="\/portal\/offerings\/#{offer.id}\/answers" method="post">/

    end

    it 'does not a form if the activity has no offering' do
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")
      page3 = act.pages.create!(:name => "Page 3", :text => "This is the last activity text.")

      get :show, :id => page1.id, :activity_id => act.id

      response.body.should_not match /<form accept-charset="UTF-8" action="\/portal\/offerings/
    end

    it 'lists pages with links to each' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")
      page3 = act.pages.create!(:name => "Page 3", :text => "This is the last activity text.")

      get :show, :id => page1.id

      response.body.should match /<a[^>]*href="\/lightweight\/activities\/#{act.id}\/pages\/#{page1.id}"[^>]*>[^<]*1[^<]*<\/a>/
      response.body.should match /<a[^>]*href="\/lightweight\/activities\/#{act.id}\/pages\/#{page2.id}"[^>]*>[^<]*2[^<]*<\/a>/
      response.body.should match /<a[^>]*href="\/lightweight\/activities\/#{act.id}\/pages\/#{page3.id}"[^>]*>[^<]*3[^<]*<\/a>/
    end

    it 'only renders the forward navigation link if it is a first page' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")
      page3 = act.pages.create!(:name => "Page 3", :text => "This is the last activity text.")

      get :show, :id => page1.id

      response.body.should match /<a class='previous disabled'>[^<]*&nbsp;[^<]*<\/a>/
      response.body.should match /<a class='next' href='\/lightweight\/activities\/#{act.id}\/pages\/#{page2.id}'>[^<]*&nbsp;[^<]*<\/a>/
    end

    it 'renders both the forward and back navigation links if it is a middle page' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")
      page3 = act.pages.create!(:name => "Page 3", :text => "This is the last activity text.")

      get :show, :id => page2.id

      response.body.should match /<a class='previous' href='\/lightweight\/activities\/#{act.id}\/pages\/#{page1.id}'>[^<]*&nbsp;[^<]*<\/a>/
      response.body.should match /<a class='next' href='\/lightweight\/activities\/#{act.id}\/pages\/#{page3.id}'>[^<]*&nbsp;[^<]*<\/a>/
    end

    it 'only renders the back navigation links on the last page' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")
      page3 = act.pages.create!(:name => "Page 3", :text => "This is the last activity text.")

      get :show, :id => page3.id

      response.body.should match /<a class='previous' href='\/lightweight\/activities\/#{act.id}\/pages\/#{page2.id}'>[^<]*&nbsp;[^<]*<\/a>/
      response.body.should match /<a class='next disabled'>[^<]*&nbsp;[^<]*<\/a>/
    end

    it 'indicates the active page with a DOM class attribute' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")

      get :show, :id => page1.id

      response.body.should match /<a href="\/lightweight\/activities\/#{act.id}\/pages\/#{page1.id}" class="active">1<\/a>/
    end

    it 'renders pagination links if it is the only page' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      get :show, :id => page1.id

      response.body.should_not match /<a class='prev'>/
      response.body.should_not match /<a class='next'>/
    end

    it 'includes a class value matching the defined theme' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :theme => 'theme-string')

      get :show, :id => page1.id

      response.body.should match /<div class='content theme-string'>/
    end

    it 'submits answers which can be parsed as Saveables' do
      # To create a Saveable, we need an Offering, a Learner, and an answered Embeddable.
      # The current portal action creating Saveables is Portal::OfferingsController#answer
      # The Learner is created from the session in that controller, so the form doesn't
      # need to provide it.
      # The offering ID should be in params[:id].
      # The answers should be in params[:questions] as something like
      # embeddable__multiple_choice_(\d+) with value embeddable__multiple_choice_choice_(\d+)\
      # embeddable__open_response_(\d+) with a string value

      # setup
      # Mock the setup_portal_student method because we don't have a current_user method (it's provided by the session)
      @learner = mock_model(Portal::Learner, :valid? => true,:[]= => true, :save => true, :destroy=> false, :delete=>false)
      controller.stub(:setup_portal_student) { @learner }
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")

      # Add the offering - this can't be mocked because it's too close to the Activity
      offer = Portal::Offering.create!
      offer.runnable = act
      offer.learners = [@learner]
      offer.save

      # set up page
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      # Add embeddables
      or1 = Embeddable::OpenResponse.create!(:name => "Open Response 1", :prompt => "Why do you think this model is cool?")

      mc1 = Embeddable::MultipleChoice.create!(:name => "Multiple choice 1", :prompt => "What color is chlorophyll?")
      Embeddable::MultipleChoiceChoice.create(:choice => 'Red', :multiple_choice => mc1)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Green', :multiple_choice => mc1)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Blue', :multiple_choice => mc1)

      page1.add_embeddable(mc1)
      page1.add_embeddable(or1)

      # get the rendering
      get :show, :id => page1.id, :offering_id => offer.id

      form_regex = /<form.*?action="\/portal\/offerings\/(\d+)\/answers"/
      response.body.should =~ form_regex
      response.body =~ form_regex
      $1.to_i.should == offer.id

      or_regex = /<textarea.*?name='questions\[embeddable__open_response_(\d+)\]'/
      response.body.should =~ or_regex
      response.body =~ or_regex
      $1.to_i.should == or1.id

      mc_regex = /<input.*?name='questions\[embeddable__multiple_choice_(\d+)\]'.*?type='radio'.*?value='embeddable__multiple_choice_choice_\d+'/
      response.body.should =~ mc_regex
      response.body =~ mc_regex
      $1.to_i.should == mc1.id

    end

    it 'displays previous answers when viewed again' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")

      # set up page
      @page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      # Add embeddables
      @open_response = Embeddable::OpenResponse.create!(:name => "Open Response 1", :prompt => "Why do you think this model is cool?")

      @multiple_choice = Embeddable::MultipleChoice.create!(:name => "Multiple choice 1", :prompt => "What color is chlorophyll?")
      Embeddable::MultipleChoiceChoice.create(:choice => 'Red', :multiple_choice => @multiple_choice)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Green', :multiple_choice => @multiple_choice)
      Embeddable::MultipleChoiceChoice.create(:choice => 'Blue', :multiple_choice => @multiple_choice)

      @page.add_embeddable(@multiple_choice)
      @page.add_embeddable(@open_response)

      @offering = Portal::Offering.create!
      @offering.runnable = act
      @offering.save

      choice = @multiple_choice.choices.last

      controller.stub(:setup_portal_student) { mock_model('Learner', :id => 1) }

      # To create a saveable with a learner_id, we need to do it directly - posts to Offering#answer won't work, because it's a stub action which isn't learner-aware.
      saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(1, @offering.id, @open_response.id)
      if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != "This is an OR answer"
        saveable_open_response.answers.create(:answer => "This is an OR answer")
      end

      saveable_mc = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(1, @offering.id, @multiple_choice.id)
      if saveable_mc.answers.empty? || saveable_mc.answers.last.answer != choice
        saveable_mc.answers.create(:choice_id => choice.id)
      end

      get :show, :id => @page.id, :offering_id => @offering.id

      or_regex = /<textarea.*?name='questions\[embeddable__open_response_(\d+)\].*?>[^<]*This is an OR answer[^<]*<\/textarea>/m
      response.body.should =~ or_regex

      mc_regex = /<input.*?checked.*?name='questions\[embeddable__multiple_choice_(\d+)\]'.*?type='radio'.*?value='embeddable__multiple_choice_choice_#{choice.id}'/
      response.body.should =~ mc_regex
    end

    it 'disables the submit button when there is no learner' do
      pending('Not sure this is required')
      controller.stub!(:setup_portal_student).and_return(nil)
      get :show, :id => @offering.id, :format => 'run_html'
      response.body.should =~ /<input.*class='disabled'.*type='submit'/
    end

    it 'shows sidebar content on pages which have it' do
      # setup
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '<p>This is sidebar text.</p>')

      get :show, :id => page1.id

      response.body.should match /<div class='sidebar'>\n<p>This is sidebar text\.<\/p>/
    end

    it 'shows related content on the last page' do
      act = Lightweight::LightweightActivity.create!(:name => "Test activity", :related => '<p>This is related content.</p>')
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      get :show, :id => page1.id

      response.body.should match /<div class='related'>\n<p>This is related content\.<\/p>/
    end

    it 'does not show related content on pages other than the last page' do
      act = Lightweight::LightweightActivity.create!(:name => "Test activity", :related => '<p>This is related content.</p>')
      page1 = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page2 = act.pages.create!(:name => "Page 2", :text => "This is the next activity text.")

      get :show, :id => page1.id

      response.body.should_not match /<div class='related'>/
    end
  end

  describe 'new' do
    it 'creates a new page and redirects to its edit page' do
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")

      get :new, :activity_id => act.id

      response.should redirect_to(edit_activity_page_path(act.id, assigns(:page)))
    end
  end

  describe 'create' do
    it 'adds an InteractivePage to the current LightweightActivity' do
      act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      activity_page_count = act.pages.length

      post :create, :activity_id => act.id

      act.reload
      act.pages.length.should == activity_page_count + 1
    end

    it 'does not route if no LightweightActivity is specified' do
      pending 'Routing changes for best_in_place broke this'
      begin
        post :create
        throw "Should not have been able to route without an ID"
      rescue ActionController::RoutingError
      end
    end
  end

  describe 'edit' do
    context 'when editing an existing page' do
      before do
        @act = Lightweight::LightweightActivity.create!(:name => "Test activity")
        @page1 = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      end

      it 'displays page fields with edit-in-place capacity' do
        pending "update for new in-place editor"
        get :edit, :id => @page1.id, :activity_id => @act.id

        # These data-object and data-attribute span attributes are characteristic of best_in_place; another edit-in-place gem might not use the same attributes.
        response.body.should match /<span[^>]+data-object='interactive_page'[^>]+data-attribute='name'[^>]*>#{@page1.name}<\/span>/
        response.body.should match /<span[^>]+data-object='interactive_page'[^>]+data-attribute='text'[^>]*>#{@page1.text}<\/span>/
        response.body.should match /<span[^>]+data-object='interactive_page'[^>]+data-attribute='sidebar'[^>]*>#{@page1.sidebar}<\/span>/
      end

      it 'has links to show the page, return to the activity, or add another page' do
        get :edit, :id => @page1.id, :activity_id => @act.id

        response.body.should match /<a[^>]+href="\/lightweight\/activities\/#{@act.id}\/pages\/#{@page1.id}"[^>]*>[\s]*See this page[\s]*<\/a>/
        response.body.should match /<a[^>]+href="\/lightweight\/activities\/#{@act.id}\/edit"[^>]*>[\s]*Return to editing #{@act.name}[\s]*<\/a>/
        response.body.should match /<a[^>]+href="\/lightweight\/activities\/#{@act.id}\/pages\/new"[^>]*>[\s]*Add another page to #{@act.name}[\s]*<\/a>/
        response.body.should match /<a[^>]+href="\/lightweight\/activities"[^<]*>[\s]*All activities[\s]*<\/a>/
      end

      it 'has links for adding MwInteractives to the page' do
        get :edit, :id => @page1.id, :activity_id => @act.id

        response.body.should match /<a[^>]+href="\/lightweight\/pages\/#{@page1.id}\/mw_interactives\/new"[^>]*>[\s]*Add interactive[\s]*<\/a>/
      
      end

      it 'has links for adding Embeddables to the page' do
        get :edit, :id => @page1.id, :activity_id => @act.id

        response.body.should match /<form[^>]+action="\/lightweight\/activities\/#{@act.id}\/pages\/#{@page1.id}\/add_embeddable"[^<]*>/
        response.body.should match /<select[^>]+name="embeddable_type"[^>]*>/
      end
    end

    it 'redirects to the Activity page if no page is editable' do
      pending "This is a pretty far-fetched scenario"
    end
  end

  describe 'update' do
    before do
      @act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      @page1 = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '')
    end

    it 'updates the specified Page with provided values' do
      post :update, {:_method => 'put', :activity_id => @act.id, :id => @page1.id, :interactive_page => { :sidebar => 'This page now has sidebar text.' }}

      @page1.reload
      @page1.sidebar.should == 'This page now has sidebar text.'
    end

    it 'redirects to the edit page with a message confirming success' do
      post :update, {:_method => 'put', :activity_id => @act.id, :id => @page1.id, :interactive_page => { :sidebar => 'This page now has sidebar text.' }}

      flash[:notice].should == "Page #{@page1.name} was updated."
      response.should redirect_to(edit_activity_page_path(@act, @page1))
    end

    it 'redirects to the edit page with a message if there is an error' do
      pending "Again, it seems to be pretty hard to feed this invalid data"

      # This actually generates an exception and a 500 error, not a failed update
      post :update, {:_method => 'put', :activity_id => @act.id, :id => @page1.id, :interactive_page => { :related => 'This page now has sidebar text.' }}

      flash[:warning].should == "There was a problem updating Page #{@page1.name}."
      response.should redirect_to(edit_activity_page_path(@act, @page1))
    end
  end

  describe 'destroy' do
    before do
      @act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      @page1 = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '')
    end

    it 'removes the page from the database and redirects to the activity edit page with a message' do
      page_count = @act.pages.length

      post :destroy, :_method => 'delete', :id => @page1.id

      @act.reload

      @act.pages.length.should == page_count - 1
      flash[:notice].should == "Page #{@page1.name} was deleted."
      begin
        Lightweight::InteractivePage.find(@page1.id)
        throw "Should not have been able to find this page"
      rescue ActiveRecord::RecordNotFound
      end
    end

    it 'does not route with no ID' do
      begin
        post :destroy, { :_method => 'delete' }
        throw "Should not have been able to route with no id"
      rescue ActionController::RoutingError
      end
    end
  end

  describe 'add_embeddable' do
    before do
      @act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      @page1 = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '')
    end

    it 'creates an arbitrary embeddable and adds it to the page' do
      xhtml_count = Embeddable::Xhtml.count()
      embeddable_count = @page1.embeddables.length
      post :add_embeddable, :activity_id => @act.id, :id => @page1.id, :embeddable_type => 'Embeddable::Xhtml'

      @page1.reload

      @page1.embeddables.count.should == embeddable_count + 1
      Embeddable::Xhtml.count().should == xhtml_count + 1
    end

    it 'redirects to the edit page' do
      post :add_embeddable, :activity_id => @act.id, :id => @page1.id, :embeddable_type => 'Embeddable::Xhtml'

      response.should redirect_to(edit_activity_page_path(@act.id, @page1.id))
    end
  end
  
  describe 'remove_embeddable' do
    before do
      @act = Lightweight::LightweightActivity.create!(:name => "Test activity")
      @page1 = @act.pages.create!(:name => "Page 1", :text => "This is the main activity text.", :sidebar => '')
    end

    it 'removes the identified embeddable from the page' do
      embeddable = Embeddable::Xhtml.create!(:name => "Xhtml 1", :content => "This is some <strong>xhtml</strong> content!")
      @page1.add_embeddable(embeddable)
      @page1.reload
      embed_count = @page1.embeddables.length
      post :remove_embeddable, :activity_id => @act.id, :id => @page1.id, :embeddable_id => embeddable.id

      @page1.reload
      @page1.embeddables.length.should == embed_count - 1
      !@page1.embeddables.include?(embeddable)
    end

    it 'redirects to the edit page' do
      embeddable = Embeddable::Xhtml.create!(:name => "Xhtml 1", :content => "This is some <strong>xhtml</strong> content!")
      @page1.add_embeddable(embeddable)
      post :remove_embeddable, :activity_id => @act.id, :id => @page1.id, :embeddable_id => embeddable.id

      response.should redirect_to(edit_activity_page_path(@act.id, @page1.id))
    end
  end
end
