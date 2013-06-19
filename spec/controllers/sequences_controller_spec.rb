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
    it "assigns all sequences as @sequences" do
      sequence
      get :index, {}
      assigns(:sequences).should eq([sequence])
    end
  end

  describe "GET show" do
    it "assigns the requested sequence as @sequence" do
      get :show, {:id => sequence.to_param}
      assigns(:sequence).should eq(sequence)
    end
  end

  describe "GET new" do
    it "assigns a new sequence as @sequence" do
      activity
      get :new, {}
      assigns(:sequence).should be_a_new(Sequence)
      assigns(:activities).should eq([activity])
    end
  end

  describe "GET edit" do
    it "assigns the requested sequence as @sequence" do
      activity
      get :edit, {:id => sequence.to_param}
      assigns(:sequence).should eq(sequence)
      assigns(:activities).should eq([activity])
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
        response.should redirect_to(Sequence.last)
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

end
