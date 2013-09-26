require 'spec_helper'

describe SequencesController do
  let (:sequence) { FactoryGirl.create(:sequence) }
  let (:activity) { FactoryGirl.create(:public_activity) }

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
      assigns(:sequences).should be_ordered_by(:updated_at_desc)
    end
  end

  describe "GET show" do
    it "assigns the requested sequence as @sequence" do
      get :show, {:id => sequence.to_param}
      assigns(:sequence).should eq(sequence)
    end

    it 'assigns a project and a theme' do
      get :show, {:id => sequence.to_param}
      assigns(:project).should_not be_nil
      assigns(:theme).should_not be_nil
    end
  end

  describe "GET new" do
    it "redirects to edit" do
      get :new, {}
      assigns(:sequence).should be_a(Sequence)
      response.should redirect_to(edit_sequence_url(assigns(:sequence)))
    end
  end

  describe "GET edit" do
    it "assigns the requested sequence as @sequence" do
      activity
      get :edit, {:id => sequence.to_param}
      assigns(:sequence).should eq(sequence)
      # User is an admin, so we should see all activities
      assigns(:activities).should eq(LightweightActivity.all)
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
        assigns(:sequence).should be_a(Sequence)
        assigns(:sequence).should be_persisted
      end

      it "redirects to the created sequence" do
        post :create, {:sequence => valid_attributes}
        response.should redirect_to(edit_sequence_url(Sequence.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sequence as @sequence" do
        # Trigger the behavior that occurs when invalid params are submitted
        Sequence.any_instance.stub(:save).and_return(false)
        post :create, {:sequence => {}}
        assigns(:sequence).should be_a_new(Sequence)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Sequence.any_instance.stub(:save).and_return(false)
        post :create, {:sequence => {}}
        response.should render_template("new")
      end
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
        Sequence.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => sequence.to_param, :sequence => {'these' => 'params'}}
      end

      it "assigns the requested sequence as @sequence" do
        put :update, {:id => sequence.to_param, :sequence => valid_attributes}
        assigns(:sequence).should eq(sequence)
      end

      it "redirects to the sequence" do
        put :update, {:id => sequence.to_param, :sequence => valid_attributes}
        response.should redirect_to(sequence)
      end
    end

    describe "with invalid params" do
      it "assigns the sequence as @sequence" do
        # Trigger the behavior that occurs when invalid params are submitted
        Sequence.any_instance.stub(:save).and_return(false)
        put :update, {:id => sequence.to_param, :sequence => {}}
        assigns(:sequence).should eq(sequence)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Sequence.any_instance.stub(:save).and_return(false)
        put :update, {:id => sequence.to_param, :sequence => {}}
        response.should render_template("edit")
      end
    end
  end

  describe 'POST add_activity' do
    it 'adds a designated activity to the sequence' do
      sequence.activities.length.should be(0)
      post :add_activity, { :id => sequence.to_param, :activity_id => activity.id }
      sequence.reload.activities.length.should be(1)
      sequence.activities.first.should == activity
    end

    it "redirects to that sequence's edit page" do
      post :add_activity, { :id => sequence.to_param, :activity_id => activity.id }
      response.should redirect_to edit_sequence_path(sequence)
    end
  end

  describe 'POST remove_activity' do
    it 'removes the designated activity from the sequence' do
      sequence.lightweight_activities << activity
      5.times do |i|
        sequence.lightweight_activities << FactoryGirl.create(:public_activity)
      end
      sequence.activities.length.should be(6)
      post :remove_activity, { :id => sequence.to_param, :activity_id => activity.id }
      sequence.reload.activities.length.should be(5)
      sequence.lightweight_activities_sequences.each_with_index do |act, index|
        act.position.should == index + 1
      end
    end

    it "redirects to that sequence's edit page" do
      post :remove_activity, { :id => sequence.to_param, :activity_id => activity.id }
      response.should redirect_to edit_sequence_path(sequence)
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
      first_join.reload.position.should be(2)
    end

    it 'redirects to the sequence edit page if request is html' do
      get :reorder_activities, { :id => sequence.to_param, :item_lightweight_activities_sequence => sequence.lightweight_activities_sequences.map { |a| a.id }.reverse }
      response.should redirect_to edit_sequence_path(sequence)
    end

    it 'returns nothing to xhr requests', :slow => true do
      pending "This takes forever and isn't terribly important"
      xhr :get, :reorder_activities, { :id => sequence.to_param, :item_lightweight_activities_sequence => sequence.lightweight_activities_sequences.map { |a| a.id }.reverse }
      response.should == ''
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
      response.should redirect_to(sequences_url)
    end
  end

  describe "#publish" do
    let(:seq_one) { Sequence.create!(:title => 'Sequence One',:description => 'Sequence One Description') }
    let(:good_body) { "{\"type\":\"Sequence\",\"name\":\"Sequence One\",\"description\":\"Sequence One Description\",\"url\":\"http://test.host/sequences/#{seq_one.id}\",\"create_url\":\"http://test.host/sequences/#{seq_one.id}\",\"activities\":[]}" }

    before(:each) do
      @url = controller.portal_url
      stub_request(:post, @url)
    end

    it "should attempt to publish to the correct portal endpoint" do
      @url.should == "#{ENV['CONCORD_PORTAL_URL']}/external_activities/publish/v2"
    end

    it "should attempt to publish to the portal" do
      get :publish, {:id => seq_one.id }
      WebMock.should have_requested(:post, @url).with(:body => good_body, :headers => {'Authorization'=>'Bearer', 'Content-Type'=>'application/json'})
    end
  end

end
