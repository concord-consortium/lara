require 'spec_helper'

describe Api::V1::DashboardController do
  let(:sequence) { FactoryGirl.create(:sequence) }
  let(:activity) { FactoryGirl.create(:activity, name: "my activity") }
  

  describe 'toc' do
    describe 'called with a sequence' do
      before(:each) do
        get :toc, params: { runnable_id: sequence.id, runnable_type: "sequences" }
      end
      let(:expected_json) { "{\"name\":\"MyString\",\"url\":\"/sequences/#{sequence.id}\",\"activities\":[]}"}

      it 'returns a json hash of the sequence' do
        expect(response).not_to be_nil
        expect(response.body).to eql expected_json
      end
    end
    describe 'called with an activity' do
      before(:each) do
        get :toc, params: { runnable_id: activity.id, runnable_type: "activities" }
      end
      let(:expected_json) { "{\"name\":\"MyString\",\"url\":\"/sequences/#{sequence.id}\",\"activities\":[]}"}

      it 'returns a json hash of the sequence including our activity' do
        expect(response).not_to be_nil
        expect(JSON.parse(response.body)).to include("url","name","activities")
        expect(JSON.parse(response.body)['activities'][0]).to include("name" => activity.name, "id" => activity.id)
      end
    end
  end

end
