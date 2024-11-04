require 'spec_helper'

describe CRater::ScoreMappingsController do
  before(:each) do
    request.env["HTTP_REFERER"] = "Request referer"
  end

  describe 'when user is an admin' do
    before(:each) do
      @user ||= FactoryGirl.create(:admin)
      sign_in @user
    end

    let(:score_map) {
      score_mapping = FactoryGirl.create(:score_mapping)
      score_mapping.user = @user
      score_mapping.save
      score_mapping
    }

    describe '#index' do
      it 'it renders index page ' do
        get :index
        expect(assigns(:filter)).not_to be_nil
        expect(response).to be_success
      end
    end

    describe '#new' do
      it 'should return success' do
        xhr :get, :new
        expect(assigns(:score_mapping)).not_to be_nil
        expect(response).to be_success
      end
    end

    describe '#create' do
      it 'creates new score_mapping record for current user' do
        score_mapping_count = CRater::ScoreMapping.count
        post :create, params: { :c_rater_score_mapping => {:description => 'score_mapping description'} }
        expect(CRater::ScoreMapping.count).to equal score_mapping_count + 1
        expect(response).to redirect_to "Request referer"
      end
    end

    describe '#edit' do
      it 'should assign a score_mapping and return success' do
        score_map
        xhr :get, :edit, {:id => score_map.id}

        expect(assigns(:score_mapping)).not_to be_nil
        expect(assigns(:score_mapping)).to eq(score_map)
        expect(response).to be_success
      end
    end

    describe '#update' do
      it 'should change database record of score_mapping' do
        score_map
        post :update, params: { :_method => 'put', :id => score_map.id, :c_rater_score_mapping => {:description => 'This score_mapping is edited'} }
        updated_record = CRater::ScoreMapping.find(score_map.id)
        expect(updated_record.description).to eq('This score_mapping is edited')
        expect(response).to redirect_to "Request referer"
      end
    end

    describe '#destroy' do
      it 'should remove the specified record from database' do
        score_map
        score_mapping_count = CRater::ScoreMapping.count
        post :destroy, params: { :_method => 'delete', :id => score_map.id }
        expect(CRater::ScoreMapping.count).to eq(score_mapping_count - 1)
        expect(response).to redirect_to "Request referer"
      end
    end
  end

  describe 'when user is anonymous' do
    describe '#create' do
      it 'should fail' do
        score_mapping_count = CRater::ScoreMapping.count
        post :create, params: { :c_rater_score_mapping => {:description => 'score_mapping description'} }
        expect(CRater::ScoreMapping.count).to equal score_mapping_count
      end
    end
  end
end
