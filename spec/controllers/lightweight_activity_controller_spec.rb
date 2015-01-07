require 'spec_helper'

# There's a slow test in here somewhere.
describe LightweightActivitiesController do
  render_views
  
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  let (:act) { 
    activity = FactoryGirl.create(:public_activity)
    activity.user = @user
    activity.save
    activity
  }
  let (:private_act) { FactoryGirl.create(:activity)}
  let (:ar)  { FactoryGirl.create(:run, :activity_id => act.id) }
  let (:page) { act.pages.create!(:name => "Page 1", :text => "This is the main activity text.") }
  let (:sequence) { FactoryGirl.create(:sequence) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => "activities/3"}.should route_to(:controller => 'lightweight_activities', :action => 'show', :id => "3")
    end
  end

  describe '#show' do
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


    describe "when the run has a page" do
      let(:seq)     { nil }
      let(:seq_run) { nil }
      let(:run) do
        mock_model(Run, {
          :last_page => page,
          :key => "4875ade4-8529-46b2-bb34-b87158f265ae",
          :sequence => seq,
          :sequence_run => seq_run,
          :increment_run_count! => nil
        })
      end
      before(:each) do
        Run.stub!(:lookup).and_return(run)
      end
      subject { get :show, :id => act.id}
      it "should redirect to the run page" do
        # page_with_response_path(@activity.id, @run.last_page.id, @run)
        subject.should redirect_to(page_with_response_path(act.id, page.id, run.key))
      end
      
      describe "when the run page is for a different activity" do
        let(:other_act) { FactoryGirl.create(:public_activity) }
        let(:page)      { other_act.pages.create!(:name => "Page 2", :text => "This page isn't in Act 1.") }
        subject { get :show, :id => act.id}
        it "should redirect to Act 2 run page." do
          subject.should redirect_to(page_with_response_path(other_act.id, page.id, run.key))
        end
      end
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
      get :show, :id => act.id
      assigns[:session_key].should_not be_nil
      response.should be_success
    end

    describe "when called from the portal" do
      # TODO: we need to abstract away these specifics in the test:
      let(:domain)    { 'http://portal.org/' }
      let(:auth_path) { Concord::AuthPortal.strategy_name_for_url(domain) }
      it "should force a new user session" do
        controller.should_receive(:sign_out).and_return(:true)
        page

        get :show, :id => act.id, :domain => domain, :externalId => "bar"
        response.should redirect_to user_omniauth_authorize_path(auth_path, :origin => request.url)
      end
    end
  end

  describe '#preview' do
    it 'calls clear_answers on the run' do
      page
      ar.should_receive(:clear_answers).and_return(:true)
      Run.should_receive(:find).and_return(ar)
      get :preview, :id => act.id
    end

    it 'renders show' do
      page
      get :preview, :id => act.id
      response.should render_template('lightweight_activities/show')
    end
  end

  describe '#summary' do

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
      response.body.should match /Response Summary for/
    end
  end

  context 'when the current user is an author' do
    # Access control/authorization is tested in spec/models/user_spec.rb
    before(:each) do
      make_collection_with_rand_modication_time(:activity,3, :publication_status => 'public', :is_official => false)
      make_collection_with_rand_modication_time(:activity,4, :publication_status => 'public', :is_official => true)
    end

    describe '#index' do
      it 'has a list of public and owned activities' do
        # User is an admin, so all public activities will be shown
        get :index
        assigns(:community_activities).should have_at_least(3).items
        assigns(:official_activities).should have(4).items
        assigns(:community_activities).should be_ordered_by 'updated_at_desc'
        assigns(:official_activities).should be_ordered_by 'updated_at_desc'
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
        LightweightActivity.any_instance.stub(:save).and_return(false)
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => { :name => 'This update will fail.'} }

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
        LightweightActivity.any_instance.stub(:save).and_return(false)
        act
        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This update will fail' } }

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

  describe '#export' do
    it "should call 'export' on the activity" do
      get :export, { :id => act.id }
      response.should be_success
    end 
  end

  describe '#resubmit_answers' do
    context 'without a response key' do
      it 'redirects to summary' do
        get :resubmit_answers, { :id => act.id }
        response.should redirect_to summary_with_response_path(act.id, assigns(:session_key))
      end
    end

    context 'with a response key' do
      let (:answer1) { FactoryGirl.create(:multiple_choice_answer, :run => ar)}
      let (:answer2) { FactoryGirl.create(:multiple_choice_answer, :run => ar)}

      before(:each) do
        act.stub(:answers => [answer1, answer2])
        LightweightActivity.stub(:find => act)
        request.env["HTTP_REFERER"] = 'http://localhost:3000/activities'
      end

      it 'marks answers as dirty' do
        [answer1, answer2]
        ar.answers.length.should_not be(0)
        answer1.should_receive(:mark_dirty)
        answer1.should_not_receive(:send_to_portal)
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
      end

      it 'calls send_to_portal for the last answer' do
        [answer1, answer2]
        ar.answers.length.should_not be(0)
        answer2.should_receive(:send_to_portal).with('Bearer ')
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
      end

      it 'sets a flash notice for success' do
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
        flash[:notice].should match /requeued for submission/
      end
    end
  end
end
