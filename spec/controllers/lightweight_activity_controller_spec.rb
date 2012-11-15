require 'spec_helper'

describe LightweightActivitiesController do
  render_views
  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => "activities/3"}.should route_to(:controller => 'lightweight_activities', :action => 'show', :id => "3")
    end
  end

  describe 'show' do
    it 'should not route when id is not valid' do
      begin
        get :show, :id => 'foo'
        throw "Should not have been able to route with id='foo'"
      rescue ActionController::RoutingError
      end
    end

    it 'should render 404 when the activity does not exist' do
      begin
        get :show, :id => 34
      rescue ActiveRecord::RecordNotFound
      end
    end

    it 'should render the activity if it exists' do
      # setup
      act = LightweightActivity.create!(:name => "Test activity")
      page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")

      # get the rendering
      get :show, :id => act.id

      response.should redirect_to activity_page_url(act, page)
    end
  end

  context 'when the current user is not an author' do
    before do
      # TODO: Better mocks to reflect the differences between anonymous and Author users
      controller.stub(:current_user, mock_model('User', :anonymous => true))
    end

    it 'should redirect to the home page with an error message' do
      pending "Access control"
      # GET Requests to index, new, edit
      # PUT and POST requests (create, update)
      # DELETE requests
    end
  end

  context 'when the current user is an author' do
    before do
      # TODO: Better mocks to reflect the differences between anonymous and Author users
      controller.stub(:current_user, mock_model('User', :has_role? => true, :id => 10))
    end

    describe 'index' do
      it 'should provide a link to create a new Lightweight Activity on the index page' do
        get :index
        response.body.should match /<a[^>]+href="\/activities\/new"[^>]*>/
      end

      it 'should provide a list of authored Lightweight Activities with edit and run links on the index page' do
        act = LightweightActivity.create!(:name => 'There should be at least one')
        get :index
        response.body.should match /<a[^>]+href="\/activities\/#{act.id}\/edit"[^>]+class="container_link"[^>]*>[\s]*#{act.name}[\s]*<\/a>/
        response.body.should match /<a[^>]+href="\/activities\/#{act.id}"[^>]*>[\s]*Run[\s]*<\/a>/
      end
    end

    describe 'new' do

      it 'should provide a form for naming and describing a Lightweight Activity' do
        get :new
        response.body.should match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        response.body.should match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
        response.body.should match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
      end
    end

    describe 'create' do
      it 'should create a new Lightweight Activity when submitted with valid data' do
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => {:name => 'Test Activity', :description => "Test Activity's description"}}

        flash[:notice].should == "Lightweight Activity Test Activity was created."
        response.should redirect_to(edit_activity_path(assigns(:activity)))
        LightweightActivity.count.should equal existing_activities + 1
      end

      it 'creates LightweightActivities owned by the current_user' do
        # pending "This is very difficult to manage in the engine."
        existing_activities = LightweightActivity.count(:conditions => {:user_id => 10})
        post :create, {:lightweight_activity => {:name => 'Owned Activity', :description => "Test Activity's description", :user_id => 10}}

        LightweightActivity.count(:conditions => {:user_id => 10}).should equal existing_activities + 1
      end

      it 'should return to the form with an error message when submitted with invalid data' do
        pending "It turns out there aren't (m)any ways to build invalid data here."
        existing_activities = LightweightActivity.count

        post :create, {}

        flash[:warning].should == 'There was a problem creating the new Lightweight Activity.'
        response.body.should match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        response.body.should match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
        response.body.should match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
        LightweightActivity.count.should equal existing_activities
      end
    end

    describe 'edit' do
      it 'should display a form showing the current name and description' do
        act = LightweightActivity.create!(:name => 'This name needs editing', :description => 'Activity to be edited')
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
    end

    describe 'update' do
      it "should change the activity's database record to show submitted data" do
        act = LightweightActivity.create!(:name => 'This name needs editing', :description => 'Activity to be edited')
        existing_activities = LightweightActivity.count

        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This name has been edited', :description => 'Activity which was edited' }}

        LightweightActivity.count.should == existing_activities

        updated = LightweightActivity.find(act.id)
        updated.name.should == 'This name has been edited'
        updated.description.should == 'Activity which was edited'
        flash[:notice].should == "Activity #{updated.name} was updated."
      end

      it "should redirect to the activity's edit page on error" do
        pending "It turns out there aren't (m)any ways to build invalid data here."
        act = LightweightActivity.create!(:name => 'This name needs editing', :description => 'Activity to be edited')

        post :update, {:_method => 'put', :id => act.id}

        flash[:warning].should == "There was a problem updating activity #{act.name}."
        response.should redirect_to(edit_activity_path(act))
      end

      it 'should change single attributes in response to XHR-submitted data' do
        act = LightweightActivity.create!(:name => 'This name needs editing', :description => 'Activity to be edited')

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
        act = LightweightActivity.create!(:name => 'Short-lived activity', :description => 'The test should delete this in a few lines')
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
  end
end
