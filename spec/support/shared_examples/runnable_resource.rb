# These shared examples are intended to be used for 5 show actions:
# /sequences/:id
# /sequences/:sequence_id/activities/:id
# /sequences/:sequence_id/activities/:activity_id/pages/:id
# /activities/:id
# /activities/:activity_id/pages/:id

# the /sequences/:id is the only one that works directly with sequence runs
# the rest work with activity runs and if they are part of sequence they will indirectly
# work with sequence runs
# there has to be a lot of variables to handle the sequence and activity run case
# it might not be worth the trouble, but it does make sure that any new features of runs
# should get added to sequence runs (if the tests get updated)

# this should be included in a controller and needs the following context
# base_params: the params passed to get as well as any route helpers
shared_examples "runnable launched without run_key" do |run_type|
  let (:run_factory_type) { run_type.model_name.underscore.to_sym}
  describe "when the user is anonymous" do
    it "redirects with a #{run_type} key in the URL" do
      result = get :show, base_params
      redirect_params = base_params.clone
      redirect_params[run_key_param_name] = assigns[run_variable_name]
      expect(result).to redirect_to(send(run_path_helper, redirect_params))
    end
    describe "when an anonymous #{run_type} already exists" do
      # we only build the new run and not create it so it won't be found by accident
      # if the lookup code is broken
      let(:new_run) { FactoryGirl.build(run_factory_type, base_factory_params) }
      let(:anon_run) { FactoryGirl.create(run_factory_type, base_factory_params) }

      before(:each) {
        # create the anonymous run
        anon_run
      }
      it "creates a new #{run_type}, it does not use the existing #{run_type}" do
        # we save the new_run during creation because sequence runs create
        # activity runs on initialization and that requires a saved model
        expect(run_type).to receive(:create!) { new_run.save; new_run }
        get :show, base_params
        expect(assigns[run_variable_name]).to eq(new_run)
      end
    end
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in user
    end
    describe "when there is a #{run_type} owned by this user" do
      let (:extra_factory_params) { {} }
      let (:run_with_user_factory_params) { base_factory_params.merge(user_id: user.id) }
      let (:owned_run) {
        factory_params = run_with_user_factory_params.merge(extra_factory_params)
        FactoryGirl.create(run_factory_type, factory_params)
      }
      before(:each) {
        owned_run
      }
      describe "when this #{run_type} has no portal properties" do
        it "finds this existing #{run_type}" do
          get :show, base_params
          expect(assigns[run_variable_name]).to eq(owned_run)
        end
      end
      describe "when this #{run_type} has portal properties" do
        let (:extra_factory_params) { {remote_endpoint: 'http://example.com', remote_id: 1} }
        let (:new_run) { FactoryGirl.build(run_factory_type, run_with_user_factory_params) }

        it "creates a new #{run_type}, it does not use the existing #{run_type}" do
          expect(run_type).to receive(:create!) { new_run.save; new_run }
          get :show, base_params
          expect(assigns[run_variable_name]).to eq(new_run)
        end
      end
    end
  end
end

shared_examples "runnable launched with run_key" do |run_type, portal_launchable|
  describe "when there is no #{run_type} with this key" do
    it "returns 404"
  end
  describe "when the user is anonymous" do
    describe "when there is an existing #{run_type} with this key" do
      describe "when this #{run_type} is anonymous" do
        it "finds this existing #{run_type}"
      end
      describe "when the #{run_type} is owned by a user" do
        it "returns 403"
      end
    end
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in user
    end
    describe "when there is an existing #{run_type} with this key" do
      describe "when this #{run_type} is anonymous" do
        it "returns 403"
      end
      describe "when the #{run_type} is owned by a different user" do
        it "returns 403"
      end
      describe "when the #{run_type} is owned by the current user" do
        describe "when this #{run_type} has no portal properties" do
          it "finds this existing #{run_type}"
        end
        describe "when this existing #{run_type} has portal properties" do
          it "finds this existing #{run_type}"
        end
      end
    end
  end
end

shared_examples "runnable launched with portal parameters" do |run_type|
  describe "when the user is anonymous" do
    # perhaps this should be a 403, but perhaps we don't want people thinking they
    # can fish for valid portal properties
    it "returns 404"
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in user
    end
    describe "when there is not a #{run_type} with matching user and portal params" do
      # to test all conditions we should create the following not really valid runs:
      #  - run with anon user and matching portal params
      #  - run with different user and matching portal params
      it "creates a #{run_type}, and redirects to a URL with the #{run_type} key"
    end
    describe "when there is a #{run_type} with matching portal params" do
      describe "when this #{run_type} is owned by the current user" do
        it "redirects to a URL with the #{run_type} key"
      end
    end
  end
end


shared_examples "runnable resource launchable by the portal" do |run_type|
  it_behaves_like "runnable launched without run_key", run_type
  it_behaves_like "runnable launched with run_key", run_type
  it_behaves_like "runnable launched with portal parameters", run_type
end

shared_examples "runnable resource not launchable by the portal" do |run_type|
  it_behaves_like "runnable launched without run_key", run_type
  it_behaves_like "runnable launched with run_key", run_type
  it "returns an error when launched with portal parameters"
end
