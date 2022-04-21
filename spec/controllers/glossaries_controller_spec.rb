require 'spec_helper'

describe GlossariesController do

  let(:author1) { FactoryGirl.create(:author) }
  let(:author2) { FactoryGirl.create(:author) }
  let(:admin) { FactoryGirl.create(:admin) }
  let (:current_user) { admin }
  let (:glossary) { FactoryGirl.create(:glossary, user: admin) }
  let (:glossary2) { FactoryGirl.create(:glossary, user: author1) }
  let (:glossary3) { FactoryGirl.create(:glossary, user: author2) }

  before(:each) do
    # We're testing access control in spec/models/user_spec.rb, so for this
    # suite we use a user with global permissions
    if current_user
      @user = current_user
      sign_in @user
    end
    glossary
    glossary2
    glossary3
  end

  describe "GET index" do
    describe "as an admin" do
      it "assigns all glossaries as @glossaries" do
        get :index
        expect(assigns(:glossaries)).to eq([glossary, glossary2, glossary3])
      end
    end
    describe "as an author" do
      let (:current_user) { author1 }
      it "assigns all glossaries as @glossaries" do
        get :index
        expect(assigns(:glossaries)).to eq([glossary, glossary2, glossary3])
      end
    end
    describe "as an anonyous user" do
      let (:current_user) { nil }
      it "assigns [] as @glossaries" do
        get :index
        expect(assigns(:glossaries)).to eq([])
      end
    end
  end

  describe "GET new" do
    it "assigns a new glossary as @glossary" do
      get :new
      expect(assigns(:glossary)).to be_a_new(Glossary)
    end
  end

  describe "GET edit" do
    it "assigns the requested glossary as @glossary" do
      get :edit, {:id => glossary.id}
      expect(assigns(:glossary)).to eq(glossary)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Glossary" do
        expect {
          post :create, {:glossary => {
            :name => "Test Glossary A"
          }}
        }.to change(Glossary, :count).by(1)
      end

      it "assigns a newly created glossary as @glossary" do
        post :create, {:glossary => {
          :name => "Test Glossary B"
        }}
        expect(assigns(:glossary)).to be_a(Glossary)
        expect(assigns(:glossary)).to be_persisted
      end

      it "redirects to the created glossary" do
        post :create, {:glossary => {
          :name => "Test Glossary C"
        }}
        expect(response).to redirect_to(edit_glossary_url(Glossary.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved glossary as @glossary" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Glossary).to receive(:save).and_return(false)
        post :create, {:glossary => {}}
        expect(assigns(:glossary)).to be_a_new(Glossary)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Glossary).to receive(:save).and_return(false)
        post :create, {:glossary => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested glossary" do
        # Assuming there are no other glossaries in the database, this
        # specifies that the Glossary created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Glossary).to receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => glossary.id, :glossary => {'these' => 'params'}}
      end

      it "assigns the requested glossary as @glossary" do
        put :update, {:id => glossary.id, :glossary => {}}
        expect(assigns(:glossary)).to eq(glossary)
      end

      it "redirects to the glossary" do
        put :update, {:id => glossary.id, :glossary => {}}
        expect(response).to redirect_to(edit_glossary_url(glossary))
      end
    end

    describe "with invalid params" do
      it "assigns the glossary as @glossary" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Glossary).to receive(:save).and_return(false)
        put :update, {:id => glossary.id, :glossary => {}}
        expect(assigns(:glossary)).to eq(glossary)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Glossary).to receive(:save).and_return(false)
        put :update, {:id => glossary.id, :glossary => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested glossary" do
      expect {
        delete :destroy, {:id => glossary.id}
      }.to change(Glossary, :count).by(-1)
    end

    it "redirects to the glossaries list" do
      delete :destroy, {:id => glossary.id}
      expect(response).to redirect_to(glossaries_url)
    end
  end

  describe "duplicate" do
    it "duplicates the requested glossary" do
      expect {
        get :duplicate, {:id => glossary.id}
      }.to change(Glossary, :count).by(1)
      expect(assigns(:new_glossary).id).not_to eq(glossary.id)
    end

    it "redirects to the glossary edit for duplicate" do
      post :duplicate, {:id => glossary.id}
      expect(response).to redirect_to(edit_glossary_url(assigns(:new_glossary)))
    end
  end

  describe "export" do
    it "exports the requested glossary" do
      get :export, {:id => glossary.id}
      expect(response).to be_success
      json_response = JSON.parse(response.body)
      expect(json_response["type"]).to eq("Glossary")
    end
  end
end
