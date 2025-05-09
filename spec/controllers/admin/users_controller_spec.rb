require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::UsersController do
  let(:target) { FactoryBot.create(:user) }

  before(:each) do
    @user ||= FactoryBot.create(:admin)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all users as @users" do
      target
      get :index
      expect(assigns(:users).include?(target)).to be_truthy
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      get :show, params: { id: target.to_param, headers: valid_session }
      expect(assigns(:user)).to eq(target)
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      get :new, params: { headers: valid_session }
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      get :edit, params: { id: target.to_param, headers: valid_session }
      expect(assigns(:user)).to eq(target)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, params: { user: FactoryBot.attributes_for(:user) }
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, params: {user: FactoryBot.attributes_for(:user) }
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it "redirects to the created user" do
        post :create, params: {user: FactoryBot.attributes_for(:user) }
        expect(response).to redirect_to(edit_admin_user_path(User.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, params: { user: {} }
        expect(assigns(:user)).to be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, params: { user: {invalid: "invalid"} }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested user as @user and updates it" do
        post :update, params: {_method: 'put', id: target.to_param, user: {is_admin: true, is_author: true} }
        expect(assigns(:user)).to eq(target)
        expect(assigns(:user).admin?).to be_truthy
        expect(assigns(:user).author?).to be_truthy
      end

      it "redirects to the user edit page" do
        post :update, params: {_method: 'put', id: target.to_param, user: valid_attributes}
        expect(response).to redirect_to(edit_admin_user_path(target))
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        put :update, params: { id: target.to_param, user: {invalid: "invalid"} }
        expect(assigns(:user)).to eq(target)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        put :update, params: {id: target.to_param, user: {invalid: "invalid"} }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      # Using the let-created user in these specs isn't useful
      user = FactoryBot.create(:user)
      expect {
        delete :destroy, params: { id: user.to_param }
      }.to change(User, :count).by(-1)
    end

    it "redirects to the admin_users list" do
      user = FactoryBot.create(:user)
      delete :destroy, params: { id: user.to_param }
      expect(response).to redirect_to(admin_users_url)
    end
  end

end
