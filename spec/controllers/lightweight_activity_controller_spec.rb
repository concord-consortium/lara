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
    activity.theme = FactoryGirl.create(:theme)
    activity.save
    activity
  }
  let (:private_act) { FactoryGirl.create(:activity)}
  let (:ar)  { FactoryGirl.create(:run, :activity_id => act.id) }
  let (:page) { act.pages.create!(:name => "Page 1", :text => "This is the main activity text.") }
  let (:sequence) { FactoryGirl.create(:sequence) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({:get => "activities/3"}).to route_to(:controller => 'lightweight_activities', :action => 'show', :id => "3")
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
      expect(assigns(:run)).not_to be_nil
    end

    it 'assigns a project and theme' do
      page
      get :show, :id => act.id
      expect(assigns(:project)).not_to be_nil
      expect(assigns(:theme)).not_to be_nil
    end

    describe "when the run has a page" do
      let(:seq)     { nil }
      let(:seq_run) { nil }
      let(:run) do
        mock_model(Run, {
          :last_page => page,
          :key => "4875ade4-8529-46b2-bb34-b87158f265ae",
          :activity => act,
          :sequence => seq,
          :sequence_run => seq_run,
          :increment_run_count! => nil
        })
      end
      before(:each) do
        allow(Run).to receive(:lookup).and_return(run)
      end
      subject { get :show, :id => act.id}
      it "should redirect to the run page" do
        # page_with_response_path(@activity.id, @run.last_page.id, @run)
        expect(subject).to redirect_to(page_with_response_path(act.id, page.id, run.key))
      end

      describe "when the run page is hidden" do
        let(:page) { act.pages.create!(:name => "Page 1", :text => "This page is hidden.", :is_hidden => true) }
        subject { get :show, :id => act.id}
        it "should not redirect to the run page" do
          expect(subject).not_to redirect_to(page_with_response_path(act.id, page.id, run.key))
          expect(response).to render_template('lightweight_activities/show')
        end
      end
      
      describe "when the run page is for a different activity" do
        let(:other_act) { FactoryGirl.create(:public_activity) }
        let(:page)      { other_act.pages.create!(:name => "Page 2", :text => "This page isn't in Act 1.") }
        subject { get :show, :id => act.id}
        it "should redirect to Act 2 run page." do
          expect(subject).to redirect_to(page_with_response_path(other_act.id, page.id, run.key))
        end
      end

      describe 'when activity has a single page layout' do
        before do
          act.layout = LightweightActivity::LAYOUT_SINGLE_PAGE
          act.save
        end
        it 'should redirect to the single page view instead' do
          get :show, :id => act.id
          expect(subject).to redirect_to(activity_single_page_with_response_path(act.id, run.key))
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
        expect(assigns(:sequence)).not_to be_nil
      end

      it 'assigns a sequence if one is in the run' do
        page
        ar.sequence = sequence
        ar.save
        get :show, :id => act.id, :response_key => ar.key
        expect(assigns(:sequence)).to eq(sequence)
      end

      it 'assigns the sequence from the URL to the run' do
        page
        ar.sequence = nil
        ar.save
        ar.reload
        get :show, :id => act.id, :response_key => ar.key, :sequence_id => sequence.id
        expect(ar.reload.sequence_id).to be(sequence.id)
      end
    end

    it 'renders the activity if it exists and is public' do
      page
      get :show, :id => act.id
      expect(assigns[:session_key]).not_to be_nil
      expect(response).to be_success
    end

    describe "when called from the portal" do
      # TODO: we need to abstract away these specifics in the test:
      let(:domain)    { 'http://portal.org/' }
      let(:auth_path) { Concord::AuthPortal.strategy_name_for_url(domain) }
      it "should force a new user session" do
        expect(controller).to receive(:sign_out).and_return(:true)
        page

        get :show, :id => act.id, :domain => domain, :externalId => "bar"
        expect(response).to redirect_to user_omniauth_authorize_path(auth_path, :origin => request.url)
      end
    end
  end

  describe '#preview' do
    it 'calls clear_answers on the run' do
      page
      expect(ar).to receive(:clear_answers).and_return(:true)
      expect(Run).to receive(:find).and_return(ar)
      get :preview, :id => act.id
    end

    it 'renders show' do
      page
      get :preview, :id => act.id
      expect(response).to render_template('lightweight_activities/show')
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
      expect(assigns(:project)).not_to be_nil
      expect(assigns(:theme)).not_to be_nil
    end

    it 'renders the summary page if the activity exists and is public' do
      page = act.pages.create!(:name => "Page 1", :text => "This is the main activity text.")
      page.add_embeddable(FactoryGirl.create(:mc_embeddable))

      get :summary, :id => act.id, :response_key => ar.key

      expect(assigns(:answers)).not_to be_nil
      expect(response.body).to match /Response Summary for/
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
        expect(assigns(:community_activities).size).to be >= 3
        expect(assigns(:official_activities).size).to eq(4)
        expect(assigns(:community_activities)).to be_ordered_by 'updated_at_desc'
        expect(assigns(:official_activities)).to be_ordered_by 'updated_at_desc'
      end
    end

    describe '#new' do
      it 'should return success' do
        get :new
        expect(assigns(:activity)).not_to be_nil
        expect(response).to be_success
      end
    end

    describe '#create' do
      it 'creates a new Lightweight Activity when submitted with valid data' do
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => {:name => 'Test Activity', :description => "Test Activity's description"}}

        expect(flash[:notice]).to eq("Lightweight Activity Test Activity was created.")
        expect(response).to redirect_to(edit_activity_path(assigns(:activity)))
        expect(LightweightActivity.count).to equal existing_activities + 1
      end

      it 'creates LightweightActivities owned by the current_user' do
        existing_activities = LightweightActivity.count(:conditions => {:user_id => @user.id})
        post :create, {:lightweight_activity => {:name => 'Owned Activity', :description => "Test Activity's description", :user_id => 10}}

        expect(LightweightActivity.count(:conditions => {:user_id => @user.id})).to equal existing_activities + 1
      end

      it 'returns to the form with an error message when submitted with invalid data' do
        allow_any_instance_of(LightweightActivity).to receive(:save).and_return(false)
        existing_activities = LightweightActivity.count

        post :create, {:lightweight_activity => { :name => 'This update will fail.'} }

        expect(flash[:warning]).to eq('There was a problem creating the new Lightweight Activity.')
        expect(response.body).to match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        expect(response.body).to match /<input[^<]+id="lightweight_activity_name"[^<]+name="lightweight_activity\[name\]"[^<]+type="text"[^<]*\/>/
        expect(response.body).to match /<textarea[^<]+id="lightweight_activity_description"[^<]+name="lightweight_activity\[description\]"[^<]*>[^<]*<\/textarea>/
        expect(LightweightActivity.count).to equal existing_activities
      end
    end

    describe 'edit' do
      it 'should assign an activity and return success' do
        act
        get :edit, {:id => act.id}

        expect(assigns(:activity)).not_to be_nil
        expect(assigns(:activity)).to eq(act)
        expect(response).to be_success
      end
    end

    describe 'update' do
      it "should change the activity's database record to show submitted data" do
        act
        existing_activities = LightweightActivity.count

        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This name has been edited', :description => 'Activity which was edited' }}

        expect(LightweightActivity.count).to eq(existing_activities)

        updated = LightweightActivity.find(act.id)
        expect(updated.name).to eq('This name has been edited')
        expect(updated.description).to eq('Activity which was edited')
        expect(flash[:notice]).to eq("Activity #{updated.name} was updated.")
      end

      it "should redirect to the activity's edit page on error" do
        allow_any_instance_of(LightweightActivity).to receive(:save).and_return(false)
        act
        post :update, {:_method => 'put', :id => act.id, :lightweight_activity => { :name => 'This update will fail' } }

        expect(flash[:warning]).to eq("There was a problem updating your activity.")
        expect(response).to redirect_to(edit_activity_path(act))
      end

      it 'should change single attributes in response to XHR-submitted data' do
        act
        xhr :post, :update, {:id => act.id, "lightweight_activity" => { "name" => "I'm editing this name with an Ajax request" } }

        expect(response.body).to match /I'm editing this name with an Ajax request/
      end
    end

    describe 'delete' do

      it 'removes the specified activity from the database with a message' do
        act
        existing_activities = LightweightActivity.count

        post :destroy, {:_method => 'delete', :id => act.id}

        expect(LightweightActivity.count).to eq(existing_activities - 1)
        expect(response).to redirect_to(activities_path)
        expect(flash[:notice]).to eq("Activity #{act.name} was deleted.")
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
        expect(page.position).to eq(old_position - 1)
        expect(page).to be === act.pages[1]
      end

      it 'does not change the position of the first item' do
        page = act.pages.first
        old_position = page.position
        get :move_up, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        expect(page.position).to eq(old_position)
        expect(page).to be === act.pages.first
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages[2]
        page_before = page.higher_item
        get :move_up, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        expect(page_before).to be === act.pages[2]
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
        expect(page.position).to eq(old_position + 1)
        expect(page).to be === act.pages[1]
      end

      it 'does not change the position of the last item' do
        page = act.pages.last
        old_position = page.position
        get :move_down, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        expect(page.position).to eq(old_position)
        expect(page).to be === act.pages.last
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages.first
        page_after = page.lower_item
        get :move_down, {:activity_id => act.id, :id => page.id}
        page.reload
        act.reload
        expect(page_after).to be === act.pages.first
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
        expect(act.pages.first.name).to eq("Page 3")
        expect(act.pages.last.name).to eq("Page 1")
      end
    end
  end

  describe '#duplicate' do
    let (:duplicate_act) {  FactoryGirl.build(:activity) }

    it "should call 'duplicate' on the activity" do
      allow(LightweightActivity).to receive(:find).and_return(act)
      expect(act).to receive(:duplicate).and_return(duplicate_act)
      get :duplicate, { :id => act.id }
    end

    it 'should redirect to edit the new activity' do
      get :duplicate, { :id => act.id }
      expect(response).to redirect_to(edit_activity_url(assigns(:new_activity)))
    end

    let (:portal_url) { "https://fake.portal.com" }

    it "should publish the new activity if asked to do so" do
      allow(LightweightActivity).to receive(:find).and_return(act)
      allow(act).to receive(:duplicate).and_return(duplicate_act)
      expect(duplicate_act).to receive(:portal_publish).with(@user, portal_url, "#{request.protocol}#{request.host_with_port}")
      get :duplicate, { :id => act.id, :add_to_portal => portal_url }
    end
  end

  describe '#export' do
    it "should call 'export' on the activity" do
      get :export, { :id => act.id }
      expect(response).to be_success
    end 
  end

  describe '#resubmit_answers' do
    context 'without a response key' do
      it 'redirects to summary' do
        get :resubmit_answers, { :id => act.id }
        expect(response).to redirect_to summary_with_response_path(act.id, assigns(:session_key))
      end
    end

    context 'with a response key' do
      let (:answer1) { FactoryGirl.create(:multiple_choice_answer, :run => ar)}
      let (:answer2) { FactoryGirl.create(:multiple_choice_answer, :run => ar)}

      before(:each) do
        allow(act).to receive_messages(:answers => [answer1, answer2])
        allow(LightweightActivity).to receive_messages(:find => act)
        request.env["HTTP_REFERER"] = 'http://localhost:3000/activities'
      end

      it 'marks answers as dirty' do
        [answer1, answer2]
        expect(ar.answers.length).not_to be(0)
        expect(answer1).to receive(:mark_dirty)
        expect(answer1).not_to receive(:send_to_portal)
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
      end

      it 'calls send_to_portal for the last answer' do
        [answer1, answer2]
        expect(ar.answers.length).not_to be(0)
        expect(answer2).to receive(:send_to_portal)
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
      end

      it 'sets a flash notice for success' do
        get :resubmit_answers, { :id => act.id, :response_key => ar.key }
        expect(flash[:notice]).to match /requeued for submission/
      end
    end
  end
end
