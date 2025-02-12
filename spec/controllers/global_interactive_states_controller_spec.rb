require 'spec_helper'

describe GlobalInteractiveStatesController do

  describe 'routing' do
    it '#create' do
      expect(post: 'runs/88e0aff5-db3f-4087-8fda-49ec579980ee/global_interactive_state').to route_to(
        controller: 'global_interactive_states', action: 'create', run_id: '88e0aff5-db3f-4087-8fda-49ec579980ee')
    end
  end

  let (:user) { FactoryGirl.create(:user) }
  before(:each) do
    sign_in user
  end

  describe '#create' do
    let (:run) { FactoryGirl.create(:run, user: user) }
    let (:new_state) { 'test 123' }

    def basic_create_test
      expect {
        post :create, params: { run_id: run.key, raw_data: new_state }
      }.to change(GlobalInteractiveState, :count).by(1)
      expect(GlobalInteractiveState.first.raw_data).to eql(new_state)
      expect(response.status).to eql(201)
    end

    context 'when there is no global interactive state connected with given run' do
      it 'should create a new one' do
        basic_create_test
      end
    end

    context 'when there is an existing global interactive state connected with given run' do
      before(:each) do
        FactoryGirl.create(:global_interactive_state, run: run)
      end
      it 'should update it' do
        expect {
          post :create, params: { run_id: run.key, raw_data: new_state }
        }.to change(GlobalInteractiveState, :count).by(0)
        expect(GlobalInteractiveState.first.raw_data).to eql(new_state)
        expect(response.status).to eql(200)
      end
    end

    describe 'authorization' do
      context "when user is trying to modify someone else's run" do
        let (:different_user) { FactoryGirl.create(:user) }
        let (:run) { FactoryGirl.create(:run, user: different_user) }
        it 'it should fail' do
          expect {
            post :create, params: { run_id: run.key, raw_data: new_state }
          }.to change(GlobalInteractiveState, :count).by(0)
          expect(response.status).to eql(401)
        end
      end

      context "when admin is trying to modify someone else's run" do
        let (:admin) { FactoryGirl.create(:admin) }
        before(:each) do
          sign_in admin
        end
        it 'should work' do
          basic_create_test
        end
      end

      context 'when anonymous user is trying to modify anonymous run' do
        before(:each) do
          sign_out user
          run.update!(user_id: nil)
        end
        it 'should work' do
          basic_create_test
        end
      end
    end
  end
end
