require 'spec_helper'

# There's a slow test in here somewhere.
describe LightweightActivitiesController do
  render_views

  it_behaves_like "remote duplicate support" do
    let(:resource) { FactoryGirl.create(:activity) }
  end

  let (:admin) { FactoryGirl.create(:admin) }
  let (:author) { FactoryGirl.create(:author) }
  let (:page) { FactoryGirl.create(:page, name: "Page 1" ) }
  # act.pages.create!(:name => "Page 1") }
  let (:theme) { FactoryGirl.create(:theme) }
  let (:project) { FactoryGirl.create(:project) }
  let (:act) {
    activity = FactoryGirl.create(:public_activity,
      user: author, theme: theme, project: project, pages: [page])
  }
  let (:private_act) { FactoryGirl.create(:activity)}
  let (:ar_run)  { FactoryGirl.create(:run, :activity_id => act.id, :user_id => nil) }
  # let (:page) { act.pages.create!(:name => "Page 1") }
  let (:sequence) { FactoryGirl.create(:sequence) }

  let (:user)    { FactoryGirl.create(:user) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({:get => "activities/3"}).to route_to(:controller => 'lightweight_activities', :action => 'show', :id => "3")
    end
  end

  describe '#show' do
    it 'renders 404 when the activity does not exist' do
      expect{
        get :show, :id => 9876548376394
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it_behaves_like "runnable resource launchable by the portal", Run do
      let(:action) { :show }
      let(:resource_template) { 'lightweight_activities/show' }
      let(:base_params) { {id: act.id} }
      let(:base_factory_params) { {activity_id: act.id}}
      let(:run_path_helper) { :activity_with_run_path }
      let(:run_key_param_name) { :run_key }
      let(:run_variable_name) { :run }
    end

    describe "when the run has a page" do
      let(:last_page) { page }
      before(:each) do
        ar_run.set_last_page(last_page)
      end
      describe "when the URL has a run_key" do
        subject { get :show, :id => act.id, :run_key => ar_run.key}

        it "should redirect to the run page" do
          # page_with_run_path(@activity.id, @run.last_page.id, @run)
          expect(subject).to redirect_to(page_with_run_path(act.id, page.id, ar_run.key))
        end

        describe "when the run page is hidden" do
          let(:page) { FactoryGirl.create(:page, name: "Page 1", is_hidden: true) }

          it "should not redirect to the run page" do
            expect(subject).not_to redirect_to(page_with_run_path(act.id, page.id, ar_run.key))
            expect(response).to render_template('lightweight_activities/show')
          end
        end

        describe "when the run page is for a different activity" do
          let(:other_act) { FactoryGirl.create(:public_activity) }
          let(:other_page) { FactoryGirl.create(:page, name: "Page 2", lightweight_activity: other_act) }
          let(:last_page) { other_page }

          it "should redirect to Act 2 run page." do
            expect(subject).to redirect_to(page_with_run_path(other_act.id, other_page.id, ar_run.key))
          end
        end

        describe 'when activity has a single page layout' do
          before(:each) do
            act.layout = LightweightActivity::LAYOUT_SINGLE_PAGE
            act.save
          end
          it 'should redirect to the single page view instead' do
            get :show, :id => act.id
            expect(subject).to redirect_to(activity_single_page_with_run_path(act.id, ar_run.key))
          end

          describe "when the URL has portal properties" do
            before(:each) do
              ar_run.remote_endpoint = 'https://example.com'
              ar_run.remote_id = 1
              ar_run.user = user
              ar_run.save
              sign_in user
            end

            subject { get :show, id: act.id,
               returnUrl: 'https://example.com', externalId: 1 }

            it "should redirect to the single page with a run key" do
              expect(subject).to redirect_to(activity_single_page_with_run_path(act.id, ar_run.key))
            end
          end

        end

      end
    end

    describe 'when it is part of a sequence' do
      let (:seq_run) { FactoryGirl.create(:sequence_run, :sequence_id => sequence.id, :user_id => nil) }

      before(:each) do
        # Add the activity to the sequence
        act.sequences = [sequence]
        act.save
      end

      it_behaves_like "runnable resource not launchable by the portal", Run do
        let(:action) { :show }
        let(:resource_template) { 'lightweight_activities/show' }
        let(:base_params) { {id: act.id, sequence_id: sequence.id} }
        let(:base_factory_params) { {activity_id: act.id, sequence_id: sequence.id,
          sequence_run: seq_run }}
        let(:run_path_helper) { :sequence_activity_with_run_path }
        let(:run_key_param_name) { :run_key }
        let(:run_variable_name) { :run }
      end


      it 'creates a sequence run and activity run if not specificied' do
        get :show, :id => act.id, :sequence_id => sequence.id
        expect(assigns(:sequence_run)).not_to be_nil
      end

      describe "when an anonymous run with a sequence run already exists" do
        before(:each) do
          ar_run.sequence = sequence
          ar_run.sequence_run = seq_run
          ar_run.save
        end

        it "assigns a sequence even if the URL doesn't have one" do
          ar_run.sequence = sequence
          ar_run.sequence_run = seq_run
          ar_run.save
          get :show, :id => act.id, :run_key => ar_run.key
          expect(assigns(:sequence)).to eq(sequence)
        end

        # this is mostly duplicated in the runnable_resource shared examples but those
        # examples don't currently check that the sequencerun is created too
        describe "when the activity is loaded without a run_key" do
          # build is used here so this new_seq_run cannot be accidentally found during a
          # broken lookup
          let(:new_seq_run) { FactoryGirl.build(:sequence_run, sequence_id: sequence.id) }

          it 'creates a new run, it does not reuse the existing run' do
            expect(new_seq_run).to_not be_persisted
            # we need to save this sequence run so the runs.create can be called later
            expect(SequenceRun).to receive(:create!) { new_seq_run.save; new_seq_run }
            get :show, sequence_id: sequence.id, id: act.id
            expect(assigns[:sequence_run]).to eq(new_seq_run)
            expect(assigns[:run].sequence_run).to eq(new_seq_run)
            expect(assigns[:run]).to_not eq(ar_run)
          end
        end
      end

      it 'assigns a sequence if one is in the URL' do
        get :show, :id => act.id, :sequence_id => sequence.id
        expect(assigns(:sequence)).not_to be_nil
      end

      describe 'when the current_user has a run with portal properties with this sequence' do

        before(:each) do
          ar_run.sequence_run = seq_run
          ar_run.sequence = sequence
          ar_run.user = user
          ar_run.remote_endpoint = 'http://example.com'
          ar_run.remote_id = 1
          ar_run.save
          sign_in user
        end

        # this is mostly duplicated by the runnable_resource shared examples but those
        # examples don't check if the SequenceRun is created
        describe 'when the URL has no parameters' do
          # build is used here so this new_seq_run cannot be accidentally found during a
          # broken lookup
          let(:new_seq_run) { FactoryGirl.build(:sequence_run, sequence_id: sequence.id) }

          it 'creates a new run, it does not reuse the existing run' do
            expect(new_seq_run).to_not be_persisted
            # we need to save this sequence run so the runs.create can be called later
            expect(SequenceRun).to receive(:create!) { new_seq_run.save; new_seq_run }
            get :show, sequence_id: sequence.id, id: act.id
            expect(assigns[:sequence_run]).to eq(new_seq_run)
            expect(assigns[:run].sequence_run).to eq(new_seq_run)
            expect(assigns[:run]).to_not eq(ar_run)
          end
        end

      end

      it 'fails if URL has a sequence but the run does not' do
        ar_run.sequence = nil
        ar_run.sequence_run = seq_run
        ar_run.save
        ar_run.reload
        expect {
          get :show, :id => act.id, :run_key => ar_run.key, :sequence_id => sequence.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "fails if the run's sequence doesn't match the URL sequence" do
        other_activity = FactoryGirl.create(:activity)
        other_sequence = FactoryGirl.create(:sequence, lightweight_activities: [other_activity])

        ar_run.sequence = sequence
        ar_run.sequence_run = seq_run
        ar_run.save
        ar_run.reload
        expect {
          get :show, :id => other_activity.id, :run_key => ar_run.key, :sequence_id => other_sequence.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'fails if the activity is not part of the sequence' do
        other_activity = FactoryGirl.create(:activity)
        expect {
          get :show, :id => other_activity.id, :sequence_id => sequence.id
        }.to raise_error(ActiveRecord::RecordNotFound)

      end
    end

  end

  describe '#preview' do
    before(:each) {
      sign_in author
    }

    it 'calls clear_answers on the run' do
      expect(Run).to receive(:lookup).and_return(ar_run)
      expect(ar_run).to receive(:clear_answers).and_return(:true)
      get :preview, :id => act.id
    end

    it 'renders show' do
      get :preview, :id => act.id
      expect(response).to render_template('lightweight_activities/show')
    end
  end

  describe "#summary" do
      before(:each) do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("https://us-central1-report-service-dev.cloudfunctions.net/api")
        allow(ENV).to receive(:[]).with("REPORT_URL").and_return("https://portal-report.concord.org/branch/master/index.html")
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return("authoring.test.concord.org")
      end

      it "redirects to external portal with the provided run" do
        get :summary, { :id => act.id, :run_key => ar_run.key }
        expect(response).to redirect_to "https://portal-report.concord.org/branch/master/index.html" +
          "?firebase-app=report-service-dev" +
          "&sourceKey=authoring.test.concord.org" +
          "&runKey=#{ar_run.key}" +
          "&activity=http%3A%2F%2Ftest.host%2Factivities%2F#{act.id}" +
          "&resourceUrl=http%3A%2F%2Ftest.host%2Factivities%2F#{act.id}"

      end
    end

  describe '#single_page' do

    it_behaves_like "runnable resource not launchable by the portal", Run do
      let(:action) { :single_page }
      let(:resource_template) { 'lightweight_activities/single' }
      let(:base_params) { {id: act.id } }
      let(:base_factory_params) { {activity_id: act.id }}
      let(:run_path_helper) { :activity_single_page_with_run_path }
      let(:run_key_param_name) { :run_key }
      let(:run_variable_name) { :run }
    end

  end

  describe '#print_blank' do
    it 'renders print_blank' do
      get :print_blank, :id => act.id
      expect(response).to render_template('lightweight_activities/print_blank')
    end
  end

  context 'when the current user is an author' do
    # Access control/authorization is tested in spec/models/user_spec.rb
    before(:each) do
      sign_in author
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
        existing_activities = LightweightActivity.count(:conditions => {:user_id => author.id})
        post :create, {:lightweight_activity => {:name => 'Owned Activity', :description => "Test Activity's description", :user_id => 10}}

        expect(LightweightActivity.count(:conditions => {:user_id => author.id})).to equal existing_activities + 1
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
        request.accept = "application/json"
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
          act.pages.create!(:name => "Page #{i}", :sidebar => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
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
          act.pages.create!(:name => "Page #{i}", :sidebar => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
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
          act.pages.create!(:name => "Page #{i}", :sidebar => "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
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
        expect(duplicate_act).to receive(:portal_publish).with(author, portal_url, "#{request.protocol}#{request.host_with_port}")
        get :duplicate, { :id => act.id, :add_to_portal => portal_url }
      end
    end
  end

  context 'when the user is an admin' do
    before(:each) do
      sign_in admin
    end

    describe '#export' do
      it "should call 'export' on the activity" do
        get :export, { :id => act.id }
        expect(response).to be_success
      end
    end

    describe '#export_for_portal' do
      it "should be routed correctly" do
        expect(get: "/activities/1/export_for_portal").to route_to(
            controller: 'lightweight_activities', action: 'export_for_portal', id: '1'
          )
      end

      it "should call 'export' on the activity" do
        get :export_for_portal, { :id => act.id }
        expect(response).to be_success
        json_response = JSON.parse(response.body)
        expect(json_response["student_report_enabled"]).to_not be_nil
      end
    end

    describe '#resubmit_answers' do
      context 'without a run key' do
        it 'redirects to activities list' do
          get :resubmit_answers, { :id => act.id }
          expect(response).to redirect_to activities_path
        end
      end

      context 'with a run key' do
        let (:answer1) { FactoryGirl.create(:multiple_choice_answer, :run => ar_run)}
        let (:answer2) { FactoryGirl.create(:multiple_choice_answer, :run => ar_run)}

        before(:each) do
          allow(act).to receive_messages(:answers => [answer1, answer2])
          allow(LightweightActivity).to receive_messages(:find => act)
          request.env["HTTP_REFERER"] = 'http://localhost:3000/activities'
        end

        it 'marks answers as dirty' do
          [answer1, answer2]
          expect(ar_run.answers.length).not_to be(0)
          expect(answer1).to receive(:mark_dirty)
          expect(answer1).not_to receive(:send_to_portal)
          get :resubmit_answers, { :id => act.id, :run_key => ar_run.key }
        end

        it 'calls send_to_portal for the last answer' do
          [answer1, answer2]
          expect(ar_run.answers.length).not_to be(0)
          expect(answer2).to receive(:send_to_portal)
          get :resubmit_answers, { :id => act.id, :run_key => ar_run.key }
        end

        it 'sets a flash notice for success' do
          get :resubmit_answers, { :id => act.id, :run_key => ar_run.key }
          expect(flash[:notice]).to match /requeued for submission/
        end
      end
    end
  end

end
