require 'spec_helper'

# There's a slow test in here somewhere.
describe LightweightActivitiesController do
  render_views
  let (:act) { FactoryGirl.create(:public_activity) }
  let (:ar) { FactoryGirl.create(:run, :activity_id => act.id) }

  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => "activities/3"}.should route_to(:controller => 'lightweight_activities', :action => 'show', :id => "3")
    end
  end

  describe '#show' do
    it 'does not route when id is not valid' do
      begin
        get :show, :id => 'foo'
        throw "Should not have been able to route with id='foo'"
      rescue ActionController::RoutingError
      end
    end

    it 'renders 404 when the activity does not exist' do
      begin
        get :show, :id => 9876548376394
      rescue ActiveRecord::RecordNotFound
      end
    end

    it 'renders the activity if it exists and is public' do
      # setup
      page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      # get the rendering
      get :show, :id => act.id

      response.should redirect_to activity_page_url(act, page)
    end
  end

  describe '#summary' do
    it 'does not route when id is not valid' do
      begin
        get :summary, :id => 'foo'
        throw "Should not have been able to route with id='foo'"
      rescue ActionController::RoutingError
      end
    end

    it 'renders 404 when the activity does not exist' do
      begin
        get :summary, :id => 9876548376394
      rescue ActiveRecord::RecordNotFound
      end
    end

    it 'renders the summary page if the activity exists and is public' do
      page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page.add_embeddable(FactoryGirl.create(:mc_embeddable))

      get :summary, :id => act.id, :response_key => ar.key

      response.body.should match /<h1>\n?Response Summary for/
    end
  end

  context 'when the current user is an author' do
    # Access control/authorization is tested in spec/models/user_spec.rb
    describe '#index' do
      it 'provides a link to create a new Lightweight Activity on the index page', :slow => true do
        get :index
        response.body.should match /<a[^>]+href="\/activities\/new"[^>]*>/
      end

      it 'provides a list of authored Lightweight Activities with edit and run links on the index page', :slow => true do
        act
        get :index
        response.body.should match /<a[^>]+href="\/activities\/[\d]+\/edit"[^>]*>[\s]*Edit[\s]*<\/a>/
        response.body.should match /<a[^>]+href="\/activities\/[\d]+"[^>]*>[\s]*Run[\s]*<\/a>/
      end
    end

    describe '#new' do

      it 'provides a form for naming and describing a Lightweight Activity' do
        get :new
        response.body.should match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        response.body.should match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
        response.body.should match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
      end
    end

    describe '#create' do
      it 'creates a new Lightweight Activity when submitted with valid data' do
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => {:name => 'Test Activity', :description => "Test Activity's description"}}

        flash[:notice].should == "Lightweight Activity Test Activity was created."
        response.should redirect_to(edit_activity_path(assigns(:activity)))
        LightweightActivity.count.should equal existing_activities + 1
      end

      it 'creates LightweightActivities owned by the current_user' do
        existing_activities = LightweightActivity.count(:conditions => {:user_id => @user.id})
        post :create, {:lightweight_activity => {:name => 'Owned Activity', :description => "Test Activity's description", :user_id => 10}}

        LightweightActivity.count(:conditions => {:user_id => @user.id}).should equal existing_activities + 1
      end

      it 'returns to the form with an error message when submitted with invalid data' do
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => {:name => 'This actvity has a really, really long name, so long it should fail to be created because the validation on the save should fail, remember there is a limit on the length of names somewhere, right? I mean, seriously, how much text do you expect to fit in a title block. You would think the designer would be ready for it to wrap, but no.'}}

        flash[:warning].should == 'There was a problem creating the new Lightweight Activity.'
        response.body.should match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        response.body.should match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
        response.body.should match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
        LightweightActivity.count.should equal existing_activities
      end
    end

    describe 'edit' do
      it 'should display a form showing the current name and description' do
        act
        get :edit, {:id => act.id}

        response.body.should match /<form[^>]+action="\/activities\/#{act.id}"[^>]+method="post"[^<]*>/
        response.body.should match /<input[^>]+name="_method"[^>]+type="hidden"[^>]+value="put"[^<]+\/>/
        response.body.should match /<input[^>]+id="lightweight_activity_name"[^>]+name="lightweight_activity\[name\]"[^>]+type="text"[^<]+value="#{act.name}"[^<]*\/>/
        response.body.should match /<span[^>]+class="editable"[^>]+data-name="lightweight_activity\[description\]"[^<]*>/
        response.body.should match /<span[^>]+class="editable"[^>]+data-name="lightweight_activity\[related\]"[^<]*>/
        response.body.should match /<a[^>]+href="\/activities"[^<]*>[\s]*All Activities[\s]*<\/a>/
      end

      it 'should include a link to add pages' do
        act = LightweightActivity.create!(:name => 'This Activity needs pages', :description => 'Activity to add pages to')
        get :edit, {:id => act.id}

        response.body.should match /<a[^>]+href="\/activities\/#{act.id}\/pages\/new"/
      end

      it 'should provide in-place editing of description and sidebar', :js => true, :slow => true do

        act

        visit new_user_session_path
        fill_in "Email", :with => @user.email
        fill_in "Password", :with => @user.password
        click_button "Sign in"
        visit edit_activity_path(act)

        find("#lightweight_activity_description_trigger").click
        page.should have_selector('#lightweight_activity_description-wysiwyg-iframe')
      end
    end

    describe 'update' do
      it "should change the activity's database record to show submitted data" do
        act
        existing_activities = LightweightActivity.count

        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This name has been edited', :description => 'Activity which was edited' }}

        LightweightActivity.count.should == existing_activities

        updated = LightweightActivity.find(act.id)
        updated.name.should == 'This name has been edited'
        updated.description.should == 'Activity which was edited'
        flash[:notice].should == "Activity #{updated.name} was updated."
      end

      it "should redirect to the activity's edit page on error" do
        act
        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This is another one of those really long names, hopefully long enough to trip validation and get this to be an invalid update'}}

        flash[:warning].should == "There was a problem updating your activity."
        response.should redirect_to(edit_activity_path(act))
      end

      it 'should change single attributes in response to XHR-submitted data' do
        act
        xhr :post, :update, {:id => act.id, "lightweight_activity" => { "name" => "I'm editing this name with an Ajax request" } }

        response.body.should match /I'm editing this name with an Ajax request/
      end
    end

    describe 'delete' do
      it 'does not route without an ID' do
        begin
          post :destroy, { :_method => 'delete' }
          throw "Should not have been able to route with no id"
        rescue ActionController::RoutingError
        end
      end

      it 'removes the specified activity from the database with a message' do
        act
        existing_activities = LightweightActivity.count

        post :destroy, {:_method => 'delete', :id => act.id}

        LightweightActivity.count.should == existing_activities - 1
        response.should redirect_to(activities_path)
        flash[:notice].should == "Activity #{act.name} was deleted."
        begin
          LightweightActivity.find(act.id)
          throw "Should not have found #{act.name}."
        rescue ActiveRecord::RecordNotFound
        end
      end
    end

    describe 'move_up' do
      before do
        [1,2,3].each do |i|
          act.pages.create!(:name => "Page #{i}", :text => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.", :sidebar => '')
        end
        request.env["HTTP_REFERER"] = "/activities/#{act.id}/edit"
      end

      it 'does not route without an id and page_id' do
        begin
          get :move_up, {:id => act.id}
          throw "Should not have been able to route with no page_id"
        rescue ActionController::RoutingError
        end
      end

      it 'decrements the position value of the page' do
        page = act.pages[2]
        old_position = page.position
        get :move_up, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page.position.should == old_position - 1
        page.should === act.pages[1]
      end

      it 'does not change the position of the first item' do
        page = act.pages.first
        old_position = page.position
        get :move_up, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page.position.should == old_position
        page.should === act.pages.first
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages[2]
        page_before = page.higher_item
        get :move_up, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page_before.should === act.pages[2]
      end
    end

    describe 'move_down' do
      before do
        [1,2,3].each do |i|
          act.pages.create!(:name => "Page #{i}", :text => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.", :sidebar => '')
        end
        request.env["HTTP_REFERER"] = "/activities/#{act.id}/edit"
      end

      it 'does not route without an id and page_id' do
        begin
          get :move_down, {:id => act.id}
          throw "Should not have been able to route with no page_id"
        rescue ActionController::RoutingError
        end
      end

      it 'increments the position value of the page' do
        page = act.pages[0]
        old_position = page.position
        get :move_down, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page.position.should == old_position + 1
        page.should === act.pages[1]
      end

      it 'does not change the position of the last item' do
        page = act.pages.last
        old_position = page.position
        get :move_down, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page.position.should == old_position
        page.should === act.pages.last
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages.first
        page_after = page.lower_item
        get :move_down, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        page_after.should === act.pages.first
      end
    end

    describe 'reorder_pages' do
      before do
        [1,2,3].each do |i|
          act.pages.create!(:name => "Page #{i}", :text => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.", :sidebar => '')
        end
      end

      it 'rearranges activity pages to match order in request' do
        # Format: item_interactive_page[]=1&item_interactive_page[]=3&item_interactive_page[]=11&item_interactive_page[]=12&item_interactive_page[]=13&item_interactive_page[]=21&item_interactive_page[]=20&item_interactive_page[]=2
        # Should provide a list of IDs in reverse order
        get :reorder_pages, {:id => act.id, :item_interactive_page => act.pages.map { |p| p.id }.reverse }
        act.reload
        act.pages.first.name.should == "Page 3"
        act.pages.last.name.should == "Page 1"
      end
    end
  end
end
