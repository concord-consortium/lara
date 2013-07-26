require 'spec_helper'

# There's a slow test in here somewhere.
describe LightweightActivitiesController do
  render_views
  let (:act) { FactoryGirl.create(:public_activity) }
  let (:private_act) { FactoryGirl.create(:activity)}
  let (:ar)  { FactoryGirl.create(:run, :activity_id => act.id) }
  let (:page) { act.pages.create!(:name => "Page 1", :text => "This is the main activity text.") }
  let (:sequence) { FactoryGirl.create(:sequence) }

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

    it 'assigns a run key' do
      page
      get :show, :id => act.id
      assigns(:run).should_not be_nil
    end

    it 'assigns a project and theme' do
      page
      get :show, :id => act.id
      assigns(:project).should_not be_nil
      assigns(:theme).should_not be_nil
    end

    describe 'when it is part of a sequence' do
      before(:each) do
        # Add the activity to the sequence
        act.sequences = [sequence]
        act.save
      end

      it 'assigns a sequence if one is in the URL' do
        page
        get :show, :id => act.id, :sequence_id => sequence.id
        assigns(:sequence).should_not be_nil
      end

      it 'assigns a sequence if one is in the run' do
        page
        ar.sequence = sequence
        ar.save
        get :show, :id => act.id, :response_key => ar.key
        assigns(:sequence).should == sequence
      end

      it 'assigns the sequence from the URL to the run' do
        page
        ar.sequence = nil
        ar.save
        ar.reload
        get :show, :id => act.id, :response_key => ar.key, :sequence_id => sequence.id
        ar.reload.sequence_id.should be(sequence.id)
      end
    end

    it 'renders the activity if it exists and is public' do
      page
      get :show, :id => act.id, :response_key => ar.key
      assigns[:session_key].should_not be_nil
      response.should be_success
    end

    describe "when called from the portal" do
      it "should force a new user session" do
        controller.should_receive(:sign_out).and_return(:true)
        page
        get :show, :id => act.id, :domain => "foo", :externalId => "bar"
        response.should redirect_to user_omniauth_authorize_path(:concord_portal)
      end
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

    it 'assigns a project and theme' do
      get :summary, :id => act.id, :response_key => ar.key
      assigns(:project).should_not be_nil
      assigns(:theme).should_not be_nil
    end

    it 'renders the summary page if the activity exists and is public' do
      page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page.add_embeddable(FactoryGirl.create(:mc_embeddable))

      get :summary, :id => act.id, :response_key => ar.key

      assigns(:answers).should_not be_nil
      response.body.should match /<h1>\n?Response Summary for/
    end
  end

  context 'when the current user is an author' do
    # Access control/authorization is tested in spec/models/user_spec.rb
    describe '#index' do
      it 'has a list of public and owned activities' do
        # User is an admin, so all activities
        get :index
        assigns(:activities).should_not be_nil
        assigns(:activities).length.should be(LightweightActivity.count)
      end
    end

    describe '#new' do
      it 'should return success' do
        get :new
        assigns(:activity).should_not be_nil
        response.should be_success
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
      it 'should assign an activity and return success' do
        act
        get :edit, {:id => act.id}

        assigns(:activity).should_not be_nil
        assigns(:activity).should == act
        response.should be_success
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
        # TODO: Instead of creating three new pages each time, can we use let?
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
        # TODO: Instead of creating three new pages each time, can we use let?
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
        # TODO: Instead of creating three new pages each time, can we use let?
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

  describe "#publish" do
    let(:act_one) do
      LightweightActivity.create!(:name => 'Activity One',
                                  :description => 'Activity One Description',
                                  :publication_status => 'public')
    end
    #let(:good_body) { act_one.serialize_for_portal('http://test.host').to_json }

    let(:good_body) { '{"type":"Activity","name":"Activity One","description":"Activity One Description","url":"http://test.host/activities/1","create_url":"http://test.host/activities/1","sections":[{"name":"Activity One Section","pages":[]}]}' }

    before(:each) do
      @url = controller.portal_url
      stub_request(:post, @url)
    end

    it "should call 'publish!' on the activity" do
      get :publish, {:id => act_one.id }
      act.publication_status.should == 'public'
    end

    it "should attempt to publish to the correct portal endpoint" do
      @url.should == "#{ENV['CONCORD_PORTAL_URL']}/external_activities/publish/v2"
    end

    it "should attempt to publish to the portal" do
      get :publish, {:id => act_one.id }
      WebMock.should have_requested(:post, @url).with(:body => good_body, :headers => {'Authorization'=>'Bearer', 'Content-Type'=>'application/json'})
    end
  end

  describe '#duplicate' do
    it "should call 'duplicate' on the activity" do
      get :duplicate, { :id => act.id }
      assigns(:new_activity).should be_a(LightweightActivity)
      assigns(:new_activity).name.should match /^Copy of #{assigns(:activity).name[0..30]}/
      assigns(:new_activity).user.should == @user
    end

    it 'should redirect to edit the new activity' do
      get :duplicate, { :id => act.id }
      response.should redirect_to(edit_activity_url(assigns(:new_activity)))
    end
  end
end
