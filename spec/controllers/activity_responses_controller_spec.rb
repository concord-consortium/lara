require 'spec_helper'

describe ActivityResponsesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity) }
  let (:act_response) {
    r = FactoryGirl.create(:activity_response)
    r.activity = activity
    r.save
    r
  }  

  describe 'routing' do
    it 'recognizes and generates #show' do
      {:get => 'activities/3/activity_responses/foobarbaz1234567'}.should route_to(:controller => 'activity_responses', :action => 'show', :activity_id => "3", :id => 'foobarbaz1234567')
    end

    it 'does not route without activity ID' do
      begin
        get :show
      rescue ActionController::RoutingError
      end
    end

    it 'requires 16 character IDs' do
      pending 'Constraints are problematic'
      begin
        get :show, :id => 'short', :activity_id => activity.id
        throw 'Should not be able to route with id "short"'
      rescue ActionController::RoutingError
      end
    end
  end

  describe '#show' do
    context 'with valid ID' do
      it 'returns a JSON object with that ID' do
        get :show, :id => act_response.key, :activity_id => activity.id
        response.code.should == '200'
        response.body.should match /\{.*#{act_response.responses}.*\}/ 
      end
    end

    context 'with new ID' do
      it 'creates a new object with that key and returns that object' do
        existing_responses = ActivityResponse.count
        get :show, :id => 'thisisanewrespon', :activity_id => activity.id
        response.code.should == '200'
        # TODO: Check that the response body includes the new key
        ActivityResponse.count.should == existing_responses+1
      end
    end

    context 'with no ID' do
      it 'creates a new object and redirects with ID' do
        existing_responses = ActivityResponse.count
        get :show, :activity_id => activity.id
        assigns(:response).should_not be_nil
        assigns(:response).activity.should === activity
        response.should redirect_to activity_activity_response(:response, activity)
      end
    end
  end

  describe '#update' do
    context 'with invalid ID' do
      it 'returns an error' do
        begin
          put :update, :id => 'foo', :activity_id => activity.id
        rescue ActionController::RoutingError
        end
      end
    end

    context 'with valid ID' do
      it 'updates the object' do
        post :update, {:_method => 'put', :id => act_response.key, :activity_id => activity.id, :activity_response => { :responses => "{ 'key': 'Updated response' }" } }
        act_response.reload
        act_response.responses.should == "{ 'key': 'Updated response' }"
      end
    end
  end
end
