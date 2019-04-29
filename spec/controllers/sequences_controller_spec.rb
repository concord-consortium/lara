require 'spec_helper'

describe SequencesController do
  let(:sequence) { FactoryGirl.create(:sequence, publication_status: 'public') }
  let(:activity) { FactoryGirl.create(:public_activity) }

  it_behaves_like "remote duplicate support" do
    let(:resource) { FactoryGirl.create(:sequence) }
  end

  # This should return the minimal set of attributes required to create a valid
  # Sequence. As you add validations to Sequence, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  before(:each) do
    # We're testing access control in spec/models/user_spec.rb, so for this
    # suite we use a user with global permissions
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe "GET index" do
    before(:each) do
      make_collection_with_rand_modication_time(:sequence,20)
      get :index, {}
    end

    it "assigns all sequences as @sequences" do
      expect(assigns(:sequences)).to be_ordered_by(:updated_at_desc)
    end
  end

  describe "GET show" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      # the run lookup logic is based on the current_user so it is better to start
      # anonymously
      sign_out @user
    end

    it "assigns the requested sequence as @sequence" do
      get :show, {:id => sequence.to_param}
      expect(assigns(:sequence)).to eq(sequence)
    end

    it 'assigns a project and a theme' do
      get :show, {:id => sequence.to_param}
      expect(assigns(:project)).not_to be_nil
      expect(assigns(:theme)).not_to be_nil
    end

    it_behaves_like "runnable resource launchable by the portal", SequenceRun do
      let(:base_params) { {id: sequence.id} }
      let(:base_factory_params) { {sequence_id: sequence.id}}
      let(:run_path_helper) { :sequence_with_sequence_run_key_path }
      let(:run_key_param_name) { :sequence_run_key }
      let(:run_variable_name) { :sequence_run }
    end

  end


  describe "GET new" do
    it "redirects to edit" do
      get :new, {}
      expect(assigns(:sequence)).to be_a(Sequence)
      expect(response).to redirect_to(edit_sequence_url(assigns(:sequence)))
    end
  end

  describe "GET edit" do
    it "assigns the requested sequence as @sequence" do
      activity
      get :edit, {:id => sequence.to_param}
      expect(assigns(:sequence)).to eq(sequence)
      # User is an admin, so we should see all activities
      expect(assigns(:activities)).to eq(LightweightActivity.all)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Sequence" do
        expect {
          post :create, {:sequence => valid_attributes}
        }.to change(Sequence, :count).by(1)
      end

      it "assigns a newly created sequence as @sequence" do
        post :create, {:sequence => valid_attributes}
        expect(assigns(:sequence)).to be_a(Sequence)
        expect(assigns(:sequence)).to be_persisted
      end

      it "redirects to the created sequence" do
        post :create, {:sequence => valid_attributes}
        expect(response).to redirect_to(edit_sequence_url(Sequence.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sequence as @sequence" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sequence).to receive(:save).and_return(false)
        post :create, {:sequence => {}}
        expect(assigns(:sequence)).to be_a_new(Sequence)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sequence).to receive(:save).and_return(false)
        post :create, {:sequence => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe 'GET duplicate' do
    it "should call 'duplicate' on the sequence" do
      get :duplicate, { :id => sequence.id }
      expect(assigns(:new_sequence)).to be_a(Sequence)
      expect(assigns(:new_sequence).title).to match(/^Copy of #{assigns(:sequence).title}/)
      expect(assigns(:new_sequence).user).to eq(@user)
    end

    it 'should redirect to edit the new sequence' do
      get :duplicate, { :id => sequence.id }
      expect(response).to redirect_to(edit_sequence_url(assigns(:new_sequence)))
    end
  end

  describe '#export' do
    it "should call 'export' on the sequence" do
      get :export, { :id => sequence.id }
      expect(response).to be_success
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sequence" do
        sequence = Sequence.create! valid_attributes
        # Assuming there are no other sequences in the database, this
        # specifies that the Sequence created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Sequence).to receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => sequence.to_param, :sequence => {'these' => 'params'}}
      end

      it "assigns the requested sequence as @sequence" do
        put :update, {:id => sequence.to_param, :sequence => valid_attributes}
        expect(assigns(:sequence)).to eq(sequence)
      end

      it "redirects to the sequence" do
        put :update, {:id => sequence.to_param, :sequence => valid_attributes}
        expect(response).to redirect_to(sequence)
      end
    end

    describe "with invalid params" do
      it "assigns the sequence as @sequence" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sequence).to receive(:save).and_return(false)
        put :update, {:id => sequence.to_param, :sequence => {}}
        expect(assigns(:sequence)).to eq(sequence)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sequence).to receive(:save).and_return(false)
        put :update, {:id => sequence.to_param, :sequence => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe 'POST add_activity' do
    it 'adds a designated activity to the sequence' do
      expect(sequence.activities.length).to be(0)
      post :add_activity, { :id => sequence.to_param, :activity_id => activity.id }
      expect(sequence.reload.activities.length).to be(1)
      expect(sequence.activities.first).to eq(activity)
    end

    it "redirects to that sequence's edit page" do
      post :add_activity, { :id => sequence.to_param, :activity_id => activity.id }
      expect(response).to redirect_to edit_sequence_path(sequence)
    end
  end

  describe 'POST remove_activity' do
    it 'removes the designated activity from the sequence' do
      sequence.lightweight_activities << activity
      5.times do |i|
        sequence.lightweight_activities << FactoryGirl.create(:public_activity)
      end
      expect(sequence.activities.length).to be(6)
      post :remove_activity, { :id => sequence.to_param, :activity_id => activity.id }
      expect(sequence.reload.activities.length).to be(5)
      sequence.lightweight_activities_sequences.each_with_index do |act, index|
        expect(act.position).to eq(index + 1)
      end
    end

    it "redirects to that sequence's edit page" do
      post :remove_activity, { :id => sequence.to_param, :activity_id => activity.id }
      expect(response).to redirect_to edit_sequence_path(sequence)
    end
  end

  describe 'GET reorder_activities' do
    let (:a1) { stub_model(LightweightActivity, :id => 1001, :name => 'Activity One')}
    let (:a2) { stub_model(LightweightActivity, :id => 1002, :name => 'Activity Two')}

    before (:each) do
      unless sequence.lightweight_activities.length > 1
        sequence.lightweight_activities << [a1, a2]
      end
    end

    it 'rearranges activity pages to match order in request' do
      # Format: item_lightweight_activity[]=1&item_lightweight_activity[]=3&item_lightweight_activity[]=11&item_lightweight_activity[]=12&item_lightweight_activity[]=13&item_lightweight_activity[]=21&item_lightweight_activity[]=20&item_lightweight_activity[]=2
      first_join = sequence.lightweight_activities_sequences.first
      get :reorder_activities, { :id => sequence.to_param, :item_lightweight_activities_sequence => sequence.lightweight_activities_sequences.map { |a| a.id }.reverse }
      expect(first_join.reload.position).to be(2)
    end

    it 'redirects to the sequence edit page if request is html' do
      get :reorder_activities, { :id => sequence.to_param, :item_lightweight_activities_sequence => sequence.lightweight_activities_sequences.map { |a| a.id }.reverse }
      expect(response).to redirect_to edit_sequence_path(sequence)
    end

    it 'returns nothing to xhr requests', :slow => true do
      skip "This takes forever and isn't terribly important"
      xhr :get, :reorder_activities, { :id => sequence.to_param, :item_lightweight_activities_sequence => sequence.lightweight_activities_sequences.map { |a| a.id }.reverse }
      expect(response).to eq('')
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested sequence" do
      sequence = Sequence.create! valid_attributes
      expect {
        delete :destroy, {:id => sequence.to_param}
      }.to change(Sequence, :count).by(-1)
    end

    it "redirects to the sequences list" do
      delete :destroy, {:id => sequence.to_param}
      expect(response).to redirect_to(sequences_url)
    end
  end

end
