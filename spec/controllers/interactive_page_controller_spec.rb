require 'spec_helper'

describe InteractivePagesController do
  # TODO: This file is far too big, and contains a lot of view/request testing which should happen there and not here.

  render_views
  let (:act) { FactoryGirl.create(:public_activity) }

  let (:page1) do
    page1 = FactoryGirl.create(:page, :lightweight_activity => act)
  end

  let (:page2) do
    page2 = FactoryGirl.create(:page, :name => "Page 2", :text => "This is the next activity text.", :lightweight_activity => act)
  end

  let (:page3) do
    page3 = FactoryGirl.create(:page, :name => "Page 3", :text => "This is the last activity text.", :lightweight_activity => act)
  end

  let (:ar) { FactoryGirl.create(:run, :activity_id => act.id) }

  let (:interactive) { FactoryGirl.create(:mw_interactive) }
  let (:sequence) { FactoryGirl.create(:sequence) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => "activities/1/pages/3"}.should route_to(:controller => 'interactive_pages', :action => 'show', :id => "3", :activity_id => "1")
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

    it 'assigns a run key' do
      get :show, :id => page1.id, :response_key => ar.key
      assigns(:run).should_not be_nil
    end

    it 'assigns a project and theme' do
      get :show, :id => page1.id, :response_key => ar.key
      assigns(:project).should_not be_nil
      assigns(:theme).should_not be_nil
    end

    it 'assigns a sequence if one is in the run' do
      page
      ar.sequence = sequence
      ar.save
      get :show, :id => page1.id, :response_key => ar.key
      assigns(:sequence).should == sequence
    end

    it 'renders the page if it exists' do

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

      xhtml1 = FactoryGirl.create(:xhtml, :content => "This is some <strong>xhtml</strong> content!")

      page1.add_embeddable(mc1)
      page1.add_embeddable(or1)
      page1.add_embeddable(xhtml1)
      page1.add_embeddable(or2)
      page1.add_embeddable(mc2)
      page1.add_interactive(interactive)

      # get the rendering
      get :show, :id => page1.id, :response_key => ar.key

      # verify the page is as expected
      response.body.should match /<iframe/m
      response.body.should match /What color is chlorophyll\?/m
      response.body.should match /Why do you think this model is cool\?/m
      response.body.should match /What would you add to it\?/m
      response.body.should match /How many protons does Helium have\?/m
      response.body.should match /This is some <strong>xhtml<\/strong> content!/m

    end

    # --- Most of this should probably go to the view spec ---
    it 'lists pages with links to each' do
      # setup
      page1
      page2
      page3
      get :show, :id => act.pages.first.id, :response_key => ar.key

      response.body.should match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages.first.id}\/#{ar.key}"[^>]*>[^<]*1[^<]*<\/a>/
      response.body.should match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages[1].id}\/#{ar.key}"[^>]*>[^<]*2[^<]*<\/a>/
      response.body.should match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages[2].id}\/#{ar.key}"[^>]*>[^<]*3[^<]*<\/a>/
    end

    it 'only renders the forward navigation link on the first page' do
      page1
      page2
      get :show, :id => act.pages.first.id, :response_key => ar.key

      response.body.should match /<a class='disabled prev'>/
      response.body.should match /<a class='next' href='\/activities\/#{act.id}\/pages\/#{act.pages[1].id}\/#{ar.key}'>/
    end

    it 'renders both the forward and back navigation links if it is a middle page' do
      page1
      page2
      page3
      get :show, :id => act.pages[1].id, :response_key => ar.key

      response.body.should match /<a class='prev' href='\/activities\/#{act.id}\/pages\/#{act.pages[0].id}\/#{ar.key}'>/
      response.body.should match /<a class='next' href='\/activities\/#{act.id}\/pages\/#{act.pages[2].id}\/#{ar.key}'>/
    end

    it 'only renders the back navigation links on the last page' do
      page1
      page2
      page3
      get :show, :id => act.pages.last.id, :response_key => ar.key

      response.body.should match /<a class='prev' href='\/activities\/#{act.id}\/pages\/#{act.pages[act.pages.length-2].id}\/#{ar.key}'>/
      response.body.should match /<a class='disabled next'>/
    end

    it 'indicates the active page with a DOM class attribute' do
      page1
      page2
      page3
      get :show, :id => act.pages.first.id, :response_key => ar.key

      response.body.should match /<a href="\/activities\/#{act.id}\/pages\/#{act.pages.first.id}\/#{ar.key}" class="pagination-link selected">1<\/a>/
    end

    it 'renders pagination links if it is the only page' do
      page1
      get :show, :id => page1.id, :response_key => ar.key

      response.body.should_not match /<a class='prev'>/
      response.body.should_not match /<a class='next'>/
    end

    it 'shows sidebar content on pages which have it' do
      page1
      get :show, :id => page1.id, :response_key => ar.key

      response.body.should match /<div class='sidebar-mod'>/
    end

    it 'shows related content on the last page' do
      page1
      get :show, :id => page1.id, :response_key => ar.key

      response.body.should match /<div class='related-mod'>/
      response.body.should match /href='\/activities\/#{act.id}\/summary\/#{ar.key}'/
    end

    it 'does not show related content on pages other than the last page' do
      page1
      page2
      get :show, :id => act.pages.first.id, :response_key => ar.key

      response.body.should_not match /<div class='related-mod'>/
    end

    it 'does not show page areas which are not selected to be shown' do
      get :show, :id => page1.id, :response_key => ar.key
      response.body.should match /<div class='sidebar-mod'>/
      page2.show_sidebar = false
      page2.save
      get :show, :id => page2.id, :response_key => ar.key
      response.body.should_not match /<div class='sidebar-mod'>/
    end
    # --- Ends section which should go to view spec ---
  end

  context 'when the current user is an author' do
    before(:each) do
      @user ||= FactoryGirl.create(:admin)
      sign_in @user
    end

    describe 'preview' do
      it 'clears answers from the run' do
      end

      it 'renders show' do
      end
    end

    describe 'new' do
      it 'creates a new page and redirects to its edit page' do
        get :new, :activity_id => act.id

        response.should redirect_to(edit_activity_page_path(act.id, assigns(:page)))
      end
    end

    describe 'create' do
      it 'adds an InteractivePage to the current LightweightActivity' do
        activity_page_count = act.pages.length

        post :create, :activity_id => act.id

        act.reload
        act.pages.length.should == activity_page_count + 1
        act.changed_by.should == @user
      end

      it 'does not route if no LightweightActivity is specified' do
        begin
          post :create
          throw "Should not have been able to route without an ID"
        rescue ActionController::RoutingError
        end
      end
    end

    describe 'edit' do
      context 'when editing an existing page' do
        it 'displays page fields with edit-in-place capacity' do
          page1.show_introduction = 1
          page1.save
          get :edit, :id => page1.id, :activity_id => act.id

          response.body.should match /<span[^>]+class="editable"[^>]+data-name="interactive_page\[name\]"[^>]*>#{page1.name}<\/span>/
          response.body.should match /<span[^>]+class="editable"[^>]+data-name="interactive_page\[text\]"[^>]*>#{page1.text}<\/span>/
        end

        it 'saves first edits made in the WYSIWYG editor', :js => true, :slow => true do
          pending 'This is an issue with the editor, not this application'
          page1.show_introduction = 1
          page1.show_interactive = 0
          page1.save

          visit new_user_session_path
          fill_in "Email", :with => @user.email
          fill_in "Password", :with => @user.password
          click_button "Sign in"
          visit edit_activity_page_path(act, page1)

          find('#interactive_page_text_trigger').click
          find('#interactive_page_text')
          within_frame('interactive_page_text-wysiwyg-iframe') do
            page.should have_content(page1.text)
            # TODO: How can I put content in the WYSIWYG editor?
          end
          find('.wysiwyg li.html').click()
          fill_in 'interactive_page[text]', :with => 'This is edited text'
          find('.editable button[type="submit"]').click
          page.should have_content('This is edited text')
        end

        it 'has links to show the page, return to the activity, or add another page' do
          get :edit, :id => page1.id, :activity_id => act.id

          response.body.should match /<a[^>]+href="\/activities\/#{act.id}\/pages\/#{page1.id}"[^>]*>[\s]*Preview[\s]*<\/a>/
          response.body.should match /<a[^>]+href="\/activities\/#{act.id}\/edit"[^>]*>[\s]*#{act.name}[\s]*<\/a>/
          response.body.should match /<a[^>]+href="\/activities\/#{act.id}\/pages\/new"[^>]*>[\s]*Add another page to #{act.name}[\s]*<\/a>/
          response.body.should match /<a[^>]+href="\/activities"[^<]*>[\s]*All Activities[\s]*<\/a>/
        end

        it 'has links for adding Embeddables to the page' do
          get :edit, :id => page1.id, :activity_id => act.id

          response.body.should match /<form[^>]+action="\/activities\/#{act.id}\/pages\/#{page1.id}\/add_embeddable"[^<]*>/
          response.body.should match /<select[^>]+name="embeddable_type"[^>]*>/
        end

        it 'has links for adding Interactives to the page' do
          get :edit, :id => page1.id, :activity_id => act.id

          response.body.should match /<form[^>]+action="\/activities\/#{act.id}\/pages\/#{page1.id}\/add_interactive"[^<]*>/
          response.body.should match /<select[^>]+name="interactive_type"[^>]*>/
        end

        it 'shows navigation links' do
          page1
          page2
          get :edit, :id => page1.id, :activity_id => act.id

          response.body.should match /<a[^>]+class='next'[^>]+href='\/activities\/#{act.id}\/pages\/#{page2.id}\/edit'[^>]*>[\s]*&nbsp;[\s]*<\/a>/
        end
      end
    end

    describe 'update' do
      it 'updates the specified Page with provided values' do
        post :update, {:_method => 'put', :activity_id => act.id, :id => page1.id, :interactive_page => { :sidebar => 'This page now has sidebar text.' }}

        page1.reload
        page1.sidebar.should == 'This page now has sidebar text.'
        act.reload
        act.changed_by.should == @user
      end

      it 'redirects to the edit page with a message confirming success' do
        post :update, {:_method => 'put', :activity_id => act.id, :id => page1.id, :interactive_page => { :sidebar => 'This page now has sidebar text.' }}

        flash[:notice].should == "Page #{page1.name} was updated."
        response.should redirect_to(edit_activity_page_path(act, page1))
      end

      it 'redirects to the edit page with a message if there is an error' do
        InteractivePage.any_instance.stub(:save).and_return(false)
        post :update, {:_method => 'put', :activity_id => act.id, :id => page1.id, :interactive_page => { :sidebar => 'This page now has sidebar text.' }}

        flash[:warning].should == "There was a problem updating Page #{page1.name}."
        response.should redirect_to(edit_activity_page_path(act, page1))
      end
    end

    describe 'destroy' do
      it 'removes the page from the database and redirects to the activity edit page with a message' do
        page1
        page2
        page_count = act.pages.length

        post :destroy, :_method => 'delete', :id => page1.id

        act.reload

        act.pages.length.should == page_count - 1
        flash[:notice].should == "Page #{page1.name} was deleted."
        act.changed_by.should == @user
        begin
          InteractivePage.find(page1.id)
          throw "Should not have been able to find this page"
        rescue ActiveRecord::RecordNotFound
        end

        page2.reload
        page2.position.should == 1
      end

      it 'does not route with no ID' do
        begin
          post :destroy, { :_method => 'delete' }
          throw "Should not have been able to route with no id"
        rescue ActionController::RoutingError
        end
      end
    end

    describe 'reorder_embeddables' do
      it 'accepts a list of embeddables in order and adjusts position values to match' do
        # Create two OpenResponse embeddables
        or1 = FactoryGirl.create(:or_embeddable)
        or2 = FactoryGirl.create(:or_embeddable)

        # Create one MultipleChoice embeddable, with choices
        mc1 = FactoryGirl.create(:mc_with_choices)

        # Create another MultipleChoice embeddable, with choices
        mc2 = FactoryGirl.create(:mc_with_choices)

        # Create an (X)HTML embeddable
        xhtml1 = FactoryGirl.create(:xhtml)

        # Add the five embeddables created above to the page. The order they are added is the starting order: first on top, last on the bottom.
        page1.add_embeddable(mc1, 1)
        page1.add_embeddable(or1, 2)
        page1.add_embeddable(xhtml1, 3)
        page1.add_embeddable(or2, 4)
        page1.add_embeddable(mc2, 5)

        # Send a reorder request with params to reverse the order
        xhr :get, :reorder_embeddables, :id => page1.id, :activity_id => act.id, :embeddable => [ "#{mc2.id}.#{mc2.class.to_s}", "#{or2.id}.#{or2.class.to_s}", "#{xhtml1.id}.#{xhtml1.class.to_s}", "#{or1.id}.#{or1.class.to_s}", "#{mc1.id}.#{mc1.class.to_s}" ]

        page1.reload
        page1.embeddables.first.should == mc2
        page1.embeddables.last.should == mc1
        page1.embeddables[2].should == xhtml1
        act.reload
        act.changed_by.should == @user
      end
    end

    describe 'add_interactive' do
      it 'creates an arbitrary interactive and adds it to the page' do
        images_count = ImageInteractive.count()
        interactives_count = page1.interactives.length
        post :add_interactive, :activity_id => act.id, :id => page1.id, :interactive_type => 'ImageInteractive'
        page1.reload
        page1.interactives.count.should == interactives_count + 1
        ImageInteractive.count().should == interactives_count + 1
      end

      it 'redirects to the edit page' do
        post :add_interactive, :activity_id => act.id, :id => page1.id, :interactive_type => 'ImageInteractive'
        interactive_id = page1.interactives.last.id
        act.reload
        act.changed_by.should == @user
        response.should redirect_to(edit_activity_page_path(act.id, page1.id, { :edit_img_int => interactive_id }))
      end

      it 'raises an error on invalid interactive_type' do
        begin
          post :add_interactive, :activity_id => act.id, :id => page1.id, :interactive_type => 'BogusInteractive'
          raise 'Should not have been able to post a bogus interactive_type'
        rescue ArgumentError
        end
      end
    end

    describe 'add_embeddable' do
      it 'creates an arbitrary embeddable and adds it to the page' do
        xhtml_count = Embeddable::Xhtml.count()
        embeddable_count = page1.embeddables.length
        post :add_embeddable, :activity_id => act.id, :id => page1.id, :embeddable_type => 'Embeddable::Xhtml'

        page1.reload

        page1.embeddables.count.should == embeddable_count + 1
        Embeddable::Xhtml.count().should == xhtml_count + 1
      end

      it 'redirects to the edit page' do
        post :add_embeddable, :activity_id => act.id, :id => page1.id, :embeddable_type => 'Embeddable::Xhtml'

        embeddable_id = page1.embeddables.last.id
        act.reload
        act.changed_by.should == @user

        response.should redirect_to(edit_activity_page_path(act.id, page1.id, { :edit_embed_xhtml => embeddable_id }))
      end

      it 'raises an error on invalid embeddable_type' do
        begin
          post :add_embeddable, :activity_id => act.id, :id => page1.id, :embeddable_type => 'Embeddable::Bogus'
          raise 'Should not have been able to post a bogus embeddable_type'
        rescue ArgumentError
        end
      end
    end

    describe 'remove_embeddable' do
      it 'removes the identified embeddable from the page' do
        embeddable = FactoryGirl.create(:xhtml)
        page1.add_embeddable(embeddable)
        page1.reload
        embed_count = page1.embeddables.length
        post :remove_embeddable, :activity_id => act.id, :id => page1.id, :embeddable_id => embeddable.id

        page1.reload
        page1.embeddables.length.should == embed_count - 1
        !page1.embeddables.include?(embeddable)
      end

      it 'redirects to the edit page' do
        embeddable = FactoryGirl.create(:xhtml)
        page1.add_embeddable(embeddable)
        post :remove_embeddable, :activity_id => act.id, :id => page1.id, :embeddable_id => embeddable.id

        act.reload
        act.changed_by.should == @user
        response.should redirect_to(edit_activity_page_path(act.id, page1.id))
      end
    end
  end
end
