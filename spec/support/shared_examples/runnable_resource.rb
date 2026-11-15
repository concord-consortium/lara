# These shared examples are used for the actions that render a run:
# /activities/:id/single_page
# /activities/:activity_id/pages/:id
# /sequences/:sequence_id/activities/:activity_id/pages/:id

# this should be included in a controller test and needs the following context
#
# The type of run being tested (Run) should be passed as an argument
#
# The following variables should be defined with let statements
#
# action: the controller action being tested
# resource_template: the template that should be rendered on success
# base_params: the base parameters of the request so a simple request will look like:
#     get action, base_params
#   these base_params are also passed to route helpers to construct redirect paths
# base_factory_params: parameters passed to FactoryBot to create an instance of the
#   run type
# run_path_helper: the name of the route helper for constructing a path to the resource
#   with a run key.
# run_key_param_name: the name of the parameter passed to this run_path_helper to
#   construct the run
# run_variable_name: the name of the instance variable assigned by the controller for
#   the run

shared_examples "runnable launched without run_key" do |run_type|
  let (:running_user) { FactoryBot.create(:user) }
  let (:run_factory_type) { run_type.model_name.to_s.underscore.to_sym}
  describe "when the user is anonymous" do
    it "redirects with a #{run_type} key in the URL" do
      result = get action, params: base_params
      redirect_params = base_params.clone
      redirect_params[run_key_param_name] = assigns[run_variable_name]
      expect(result).to redirect_to(send(run_path_helper, redirect_params))
    end
    describe "when an anonymous #{run_type} already exists" do
      # we only build the new run and not create it so it won't be found by accident
      # if the lookup code is broken
      let(:new_run) { FactoryBot.build(run_factory_type, base_factory_params) }
      let(:anon_factory_params){ base_factory_params.merge(user_id: nil) }
      let(:anon_run) { FactoryBot.create(run_factory_type, anon_factory_params) }

      before(:each) {
        # create the anonymous run
        anon_run
      }
      it "creates a new #{run_type}, it does not use the existing #{run_type}" do
        expect(run_type).to receive(:create!) { new_run.save; new_run }
        get action, params: base_params
        expect(assigns[run_variable_name]).to eq(new_run)
      end
    end
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in running_user
    end
    describe "when there is a #{run_type} owned by this user" do
      let (:extra_factory_params) { {} }
      let (:run_with_user_factory_params) { base_factory_params.merge(user_id: running_user.id) }
      let (:owned_run) {
        factory_params = run_with_user_factory_params.merge(extra_factory_params)
        FactoryBot.create(run_factory_type, factory_params)
      }
      before(:each) {
        owned_run
      }
      describe "when this #{run_type} has no portal properties" do
        it "finds this existing #{run_type}" do
          get action, params: base_params
          expect(assigns[run_variable_name]).to eq(owned_run)
        end
      end
      describe "when this #{run_type} has portal properties" do
        let (:extra_factory_params) { {remote_endpoint: 'http://example.com', remote_id: 1} }
        let (:new_run) { FactoryBot.build(run_factory_type, run_with_user_factory_params) }

        it "creates a new #{run_type}, it does not use the existing #{run_type}" do
          expect(run_type).to receive(:create!) { new_run.save; new_run }
          get action, params: base_params
          expect(assigns[run_variable_name]).to eq(new_run)
        end
      end
    end
  end
end

shared_examples "runnable launched with run_key" do |run_type|
  let (:running_user) { FactoryBot.create(:user) }
  let (:run_factory_type) { run_type.model_name.to_s.underscore.to_sym}
  describe "when there is no #{run_type} with this key" do
    it "returns 404" do
      params_with_invalid_run_key = base_params.clone()
      params_with_invalid_run_key[run_key_param_name] = UUIDTools::UUID.random_create.to_s
      expect{
        get action, params: params_with_invalid_run_key
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "when there is an existing #{run_type} with this key" do
    let (:existing_run) { FactoryBot.create(run_factory_type, existing_run_factory_params) }
    let (:params_with_existing_run_key) {
      params = base_params.clone()
      params[run_key_param_name] = existing_run.key
      params
    }
    before(:each){
      existing_run
    }

    describe "when the user is anonymous" do
      before(:each){
        get action, params: params_with_existing_run_key
      }
      describe "when this #{run_type} is anonymous" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: nil) }
        it "finds this existing #{run_type}" do
          expect(assigns[run_variable_name]).to eq(existing_run)
        end

        it 'returns success' do
          expect(response).to be_successful
        end

        it 'renders the resource' do
          expect(response).to render_template(resource_template)
        end

        it 'assigns a project' do
          expect(assigns(:project)).not_to be_nil
        end
      end
      describe "but the #{run_type} is owned by a user" do
        let (:other_user) { FactoryBot.create(:user) }
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: other_user.id) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end

        it 'renders unauthorized run message' do
          expect(response).to render_template('runs/unauthorized_run')
        end

        it 'uses the project of the resource' do
          expect(assigns(:project)).to eq(project)
        end

      end
    end

    describe "when a user is signed in" do
      before(:each) do
        sign_in running_user
        get action, params: params_with_existing_run_key
      end
      describe "when this #{run_type} is anonymous" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: nil) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end
        describe "when the current user is an admin" do
          let (:running_user) { FactoryBot.create(:admin) }
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end

          it 'returns success' do
            expect(response).to be_successful
          end

          it 'renders the resource' do
            expect(response).to render_template(resource_template)
          end
        end
      end
      describe "when the #{run_type} is owned by a different user" do
        let (:other_user) { FactoryBot.create(:user) }
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: other_user.id) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end

        describe "when the current user is an admin" do
          let (:running_user) { FactoryBot.create(:admin) }
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end

          it 'returns success' do
            expect(response).to be_successful
          end

          it 'renders the resource' do
            expect(response).to render_template(resource_template)
          end
        end
      end
      describe "when the #{run_type} is owned by the current user" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: running_user.id) }
        describe "when this #{run_type} has no portal properties" do
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end

          it 'returns success' do
            expect(response).to be_successful
          end

          it 'renders the resource' do
            expect(response).to render_template(resource_template)
          end
        end
        describe "when this existing #{run_type} has portal properties" do
          let (:existing_run_factory_params) {
            super().merge(remote_endpoint: 'http://example.com', remote_id: 1) }
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end
        end
      end
    end
  end
end

shared_examples "runnable resource not launchable by the portal" do |run_type|
  it_behaves_like "runnable launched without run_key", run_type
  it_behaves_like "runnable launched with run_key", run_type
  describe "when launched with portal parameters" do
    before(:each) do
      sign_in FactoryBot.create(:user)
    end
    it "returns an error" do
      with_portal_params = base_params.merge(returnUrl: 'https:/example.com', externalId: 1)
      expect {
        get action, params: with_portal_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
