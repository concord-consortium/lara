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
  let (:project) { FactoryGirl.create(:project) }
  let (:act) {
    activity = FactoryGirl.create(:public_activity,
      user: author, project: project, pages: [page])
  }
  let (:private_act) { FactoryGirl.create(:activity)}
  let (:ar_run)  { FactoryGirl.create(:run, activity_id: act.id, user_id: nil) }
  # let (:page) { act.pages.create!(:name => "Page 1") }
  let (:sequence) { FactoryGirl.create(:sequence) }

  let (:user)    { FactoryGirl.create(:user) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({get: "activities/3"}).to route_to(controller: 'lightweight_activities', action: 'show', id: "3")
    end
  end

  describe '#show' do
    it 'renders 404 when the activity does not exist' do
      expect{
        get :show, params: { id: 9876548376394 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects to AP with the correct activity" do
      uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
      query = Rack::Utils.parse_query(uri.query)
      query["activity"] = "#{api_v1_activity_url(act[:id])}.json"
      uri.query = Rack::Utils.build_query(query)

      get :show, params: { id: act[:id] }
      expect(response).to redirect_to uri.to_s
    end

    it "redirects to AP with the correct sequence" do
      sequence_with_activity = FactoryGirl.create(:sequence_with_activity)

      uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
      query = Rack::Utils.parse_query(uri.query)
      query["sequence"] = "#{api_v1_sequence_url(sequence_with_activity[:id])}.json"
      query["sequenceActivity"] = "activity_#{sequence_with_activity.activities[0].id}"
      uri.query = Rack::Utils.build_query(query)

      get :show, params: { sequence_id: sequence_with_activity[:id], id: sequence_with_activity.activities[0].id }
      expect(response).to redirect_to uri.to_s
    end

    it "redirects to AP with a run key if given one" do
      uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
      query = Rack::Utils.parse_query(uri.query)
      query["activity"] = "#{api_v1_activity_url(act[:id])}.json"
      query["runKey"] = ar_run.key
      uri.query = Rack::Utils.build_query(query)

      get :show, params: { id: act[:id], run_key: ar_run.key }
      expect(response).to redirect_to uri.to_s
    end
  end

    describe '#preview' do
    before(:each) {
      sign_in author
    }

    it 'calls clear_answers on the run' do
      expect(Run).to receive(:lookup).and_return(ar_run)
      expect(ar_run).to receive(:clear_answers).and_return(:true)
      get :preview, params: { id: act.id }
    end

    it 'renders show' do
      get :preview, params: { id: act.id }
      expect(response).to render_template('lightweight_activities/show')
    end
  end

  describe "#summary" do
      before(:each) do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return("http://test.host")
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("https://us-central1-report-service-dev.cloudfunctions.net/api")
        allow(ENV).to receive(:[]).with("REPORT_URL").and_return("https://portal-report.concord.org/branch/master/index.html")
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return("authoring.test.concord.org")
      end

      it "redirects to external portal with the provided run" do
        get :summary, params: { id: act.id, run_key: ar_run.key }
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
      let(:resource_template) { 'lightweight_activities/single_page' }
      let(:base_params) { {id: act.id } }
      let(:base_factory_params) { {activity_id: act.id }}
      let(:run_path_helper) { :activity_single_page_with_run_path }
      let(:run_key_param_name) { :run_key }
      let(:run_variable_name) { :run }
    end

  end

  describe '#print_blank' do
    it 'renders print_blank' do
      get :print_blank, params: { id: act.id }
      expect(response).to render_template('lightweight_activities/print_blank')
    end
  end

  context 'when the current user is an author' do
    # Access control/authorization is tested in spec/models/user_spec.rb
    before(:each) do
      sign_in author
      make_collection_with_rand_modication_time(:activity,3, publication_status: 'public', is_official: false)
      make_collection_with_rand_modication_time(:activity,4, publication_status: 'public', is_official: true)
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

        post :create, params: { lightweight_activity: {name: 'Test Activity', description: "Test Activity's description"} }

        expect(flash[:notice]).to eq("Lightweight Activity Test Activity was created.")
        expect(response).to redirect_to(edit_activity_path(assigns(:activity)))
        expect(LightweightActivity.count).to equal existing_activities + 1
      end

      it 'creates LightweightActivities owned by the current_user' do
        existing_activities = LightweightActivity.where(user_id: author.id).count
        post :create, params: { lightweight_activity: {name: 'Owned Activity', description: "Test Activity's description", user_id: 10} }

        expect(LightweightActivity.where(user_id: author.id).count).to equal existing_activities + 1
      end

      it 'returns to the form with an error message when submitted with invalid data' do
        allow_any_instance_of(LightweightActivity).to receive(:save).and_return(false)
        existing_activities = LightweightActivity.count

        post :create, params: { lightweight_activity: { name: 'This update will fail.'} }

        expect(flash[:warning]).to eq('There was a problem creating the new Lightweight Activity.')
        expect(response.body).to match /<form[^<]+action="\/activities"[^<]+method="post"[^<]*>/
        assert_select 'input[name=?]', 'lightweight_activity[name]'
        assert_select 'textarea[name=?]', 'lightweight_activity[description]'
        expect(LightweightActivity.count).to equal existing_activities
      end
    end

    describe 'edit' do
      it 'should assign an activity and return success' do
        act
        get :edit, params: { id: act.id }

        expect(assigns(:activity)).not_to be_nil
        expect(assigns(:activity)).to eq(act)
        expect(response).to be_success
      end
    end

    describe 'update' do
      it "should change the activity's database record to show submitted data" do
        act
        existing_activities = LightweightActivity.count

        post :update, params: { _method: 'put', id: act.id, lightweight_activity: { name: 'This name has been edited', description: 'Activity which was edited' } }

        expect(LightweightActivity.count).to eq(existing_activities)

        updated = LightweightActivity.find(act.id)
        expect(updated.name).to eq('This name has been edited')
        expect(updated.description).to eq('Activity which was edited')
        expect(flash[:notice]).to eq("Activity #{updated.name} was updated.")
      end

      it "should redirect to the activity's edit page on error" do
        allow_any_instance_of(LightweightActivity).to receive(:save).and_return(false)
        act
        post :update, params: { _method: 'put', id: act.id, lightweight_activity: { name: 'This update will fail' } }

        expect(flash[:warning]).to eq("There was a problem updating your activity.")
        expect(response).to redirect_to(edit_activity_path(act))
      end

      it 'should change single attributes in response to XHR-submitted data' do
        act
        request.accept = "application/json"
        put, :update, params: {:id => act.id, "lightweight_activity" => { "name" => "I'm editing this name with an Ajax request" } }, xhr: true

        expect(response.body).to match /I'm editing this name with an Ajax request/
      end
    end

    describe 'delete' do

      it 'removes the specified activity from the database with a message' do
        act
        existing_activities = LightweightActivity.count

        post :destroy, params: { _method: 'delete', id: act.id }

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
          act.pages.create!(name: "Page #{i}", sidebar: "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
        end
        request.env["HTTP_REFERER"] = "/activities/#{act.id}/edit"
      end


      it 'decrements the position value of the page' do
        page = act.pages[2]
        old_position = page.position
        get :move_up, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page.position).to eq(old_position - 1)
        expect(page).to be === act.pages[1]
      end

      it 'does not change the position of the first item' do
        page = act.pages.first
        old_position = page.position
        get :move_up, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page.position).to eq(old_position)
        expect(page).to be === act.pages.first
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages[2]
        page_before = page.higher_item
        get :move_up, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page_before).to be === act.pages[2]
      end
    end

    describe 'move_down' do
      before do
        # TODO: Instead of creating three new pages each time, can we use let?
        [1,2,3].each do |i|
          act.pages.create!(name: "Page #{i}", sidebar: "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
        end
        request.env["HTTP_REFERER"] = "/activities/#{act.id}/edit"
      end

      it 'increments the position value of the page' do
        page = act.pages[0]
        old_position = page.position
        get :move_down, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page.position).to eq(old_position + 1)
        expect(page).to be === act.pages[1]
      end

      it 'does not change the position of the last item' do
        page = act.pages.last
        old_position = page.position
        get :move_down, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page.position).to eq(old_position)
        expect(page).to be === act.pages.last
      end

      it 'adjusts the positions of surrounding items correctly' do
        page = act.pages.first
        page_after = page.lower_item
        get :move_down, params: { activity_id: act.id, id: page.id }
        page.reload
        act.reload
        expect(page_after).to be === act.pages.first
      end
    end

    describe 'reorder_pages' do
      before do
        # TODO: Instead of creating three new pages each time, can we use let?
        [1,2,3].each do |i|
          act.pages.create!(name: "Page #{i}", sidebar: "This is the #{ActiveSupport::Inflector.ordinalize(i)} page.")
        end
      end

      it 'rearranges activity pages to match order in request' do
        # Format: item_interactive_page[]=1&item_interactive_page[]=3&item_interactive_page[]=11&item_interactive_page[]=12&item_interactive_page[]=13&item_interactive_page[]=21&item_interactive_page[]=20&item_interactive_page[]=2
        # Should provide a list of IDs in reverse order
        get :reorder_pages, params: { id: act.id, item_interactive_page: act.pages.map { |p| p.id }.reverse }
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
        get :duplicate, params: { id: act.id }
      end

      it 'should redirect to edit the new activity' do
        get :duplicate, params: { id: act.id }
        expect(response).to redirect_to(edit_activity_url(assigns(:new_activity)))
      end

      let (:portal_url) { "https://fake.portal.com" }

      it "should publish the new activity if asked to do so" do
        allow(LightweightActivity).to receive(:find).and_return(act)
        allow(act).to receive(:duplicate).and_return(duplicate_act)
        expect(duplicate_act).to receive(:portal_publish).with(author, portal_url, "#{request.protocol}#{request.host_with_port}")
        get :duplicate, params: { id: act.id, add_to_portal: portal_url }
      end
    end
  end

  context 'when the user is an admin' do
    before(:each) do
      sign_in admin
    end

    describe '#export' do
      it "should call 'export' on the activity" do
        get :export, params: { id: act.id }
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
        get :export_for_portal, params: { id: act.id }
        expect(response).to be_success
        json_response = JSON.parse(response.body)
        expect(json_response["student_report_enabled"]).to_not be_nil
      end
    end

    describe '#resubmit_answers' do
      context 'without a run key' do
        it 'redirects to activities list' do
          get :resubmit_answers, params: { id: act.id }
          expect(response).to redirect_to activities_path
        end
      end

      context 'with a run key' do
        let (:answer1) { FactoryGirl.create(:multiple_choice_answer, run: ar_run)}
        let (:answer2) { FactoryGirl.create(:multiple_choice_answer, run: ar_run)}

        before(:each) do
          allow(act).to receive_messages(answers: [answer1, answer2])
          allow(LightweightActivity).to receive_messages(find: act)
          request.env["HTTP_REFERER"] = 'http://localhost:3000/activities'
        end

        it 'marks answers as dirty' do
          [answer1, answer2]
          expect(ar_run.answers.length).not_to be(0)
          expect(answer1).to receive(:mark_dirty)
          expect(answer1).not_to receive(:send_to_portal)
          get :resubmit_answers, params: { id: act.id, run_key: ar_run.key }
        end

        it 'calls send_to_portal for the last answer' do
          [answer1, answer2]
          expect(ar_run.answers.length).not_to be(0)
          expect(answer2).to receive(:send_to_portal)
          get :resubmit_answers, params: { id: act.id, run_key: ar_run.key }
        end

        it 'sets a flash notice for success' do
          get :resubmit_answers, params: { id: act.id, run_key: ar_run.key }
          expect(flash[:notice]).to match /requeued for submission/
        end
      end
    end
  end

end
