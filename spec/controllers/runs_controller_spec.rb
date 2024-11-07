require 'spec_helper'

describe RunsController do
  render_views
  let (:activity) { FactoryGirl.create(:activity) }
  let (:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.save
    r
  }

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({get: 'activities/3/runs/88e0aff5-db3f-4087-8fda-49ec579980ee'}).to route_to(controller: 'runs', action: 'show', activity_id: "3", id: '88e0aff5-db3f-4087-8fda-49ec579980ee')
    end

    it 'does not route without activity ID' do
      begin
        get :show
      rescue ActionController::UrlGenerationError
      end
    end

  end

  describe '#index' do
    it 'creates a new object and redirects to #show' do
      existing_responses = Run.count
      get :index, params: { activity_id: activity.id }
      expect(assigns(:run)).not_to be_nil
      expect(assigns(:run).activity).to be === activity
      expect(response).to redirect_to action: 'show', activity_id: activity.id, id: assigns(:run).key
    end
  end

  describe '#dirty' do
    let (:dirty_run) { FactoryGirl.create(:run, is_dirty: true, created_at: 15.minutes.ago, updated_at: 14.minutes.ago) }

    it 'assigns @runs with dirty runs older than 5 minutes' do
      dirty_run
      # Have to be logged in
      @user ||= FactoryGirl.create(:admin)
      sign_in @user
      get :dirty
      expect(assigns(:runs)).to eq([dirty_run])
      expect(response).to render_template('dirty')
    end

    it 'returns simple JSON when requested' do
      # JSON request can be anonymous
      dirty_run
      get :dirty, format: 'json'
      expect(assigns(:runs)).to eq([dirty_run])
      expect(response.body).to match /\"dirty_runs\":\w*1/
    end
  end

  describe '#show' do
    context 'with valid ID' do
      it 'returns a JSON object with that ID' do
        get :show, params: { id: run.key, activity_id: activity.id }
        expect(response.code).to eq('200')
        # TODO: what should the body include?
        expect(response.body).to match "multiple_choice_answers"
        expect(response.body).to match "open_response_answers"
      end
    end

    context 'with new ID' do
      it 'creates a new object with that key and returns that object' do
        existing_responses = Run.count
        get :show, params: { id: '88e0aff5-db3f-4087-8fda-49ec579980ef', activity_id: activity.id }
        expect(response.code).to eq('200')
        # TODO: Check that the response body includes the new key
        expect(Run.count).to eq(existing_responses+1)
      end
    end
  end
end
