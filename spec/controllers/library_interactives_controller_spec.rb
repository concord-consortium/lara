require 'spec_helper'

describe LibraryInteractivesController do

  let(:valid_attributes) {
    {
      aspect_ratio_method: "DEFAULT",
      authoring_guidance: "valid authoring_guidance",
      base_url: "http://example.com/",
      click_to_play: false,
      click_to_play_prompt: "valid click_to_play_prompt",
      description: "valid description",
      enable_learner_state: false,
      hide_question_number: false,
      full_window: false,
      has_report_url: false,
      image_url: "http://example.com/image_url.jpg",
      name: "valid name",
      native_height: 100,
      native_width: 200,
      no_snapshots: false,
      show_delete_data_button: false,
      thumbnail_url: "http://example.com/thumbnail_url.jpg"
    }
  }

  let(:invalid_attributes) {
    {
      base_url: "does not start with protocol",
      native_height: "invalid",
      native_width: "invalid",
    }
  }

  describe "as as admin" do
    before(:each) do
      @user = FactoryBot.create(:admin)
      sign_in @user
    end

    describe "GET #index" do
      it "returns a success response" do
        LibraryInteractive.create! valid_attributes
        get :index
        expect(response).to be_successful
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        library_interactive = LibraryInteractive.create! valid_attributes
        get :edit, params: { id: library_interactive.to_param }
        expect(response).to be_successful
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new LibraryInteractive" do
          expect {
            post :create, params: { library_interactive: valid_attributes }
          }.to change(LibraryInteractive, :count).by(1)
        end

        it "redirects to the library_interactive index" do
          post :create, params: { library_interactive: valid_attributes }
          expect(response).to redirect_to(library_interactives_url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { library_interactive: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {name: "new name"}
        }

        it "updates the requested library_interactive" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, params: { id: library_interactive.to_param, library_interactive: new_attributes }
          library_interactive.reload
          expect(library_interactive.name).to eq("new name")
        end

        it "redirects to the library_interactive index" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, params: { id: library_interactive.to_param, library_interactive: valid_attributes }
          expect(response).to redirect_to(library_interactives_url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, params: { id: library_interactive.to_param, library_interactive: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe "GET #migrate" do
      it "returns a success response" do
        library_interactive = LibraryInteractive.create! valid_attributes
        get :migrate, params: { id: library_interactive.to_param, library_interactive: valid_attributes }
        expect(response).to be_successful
      end
    end

    describe "PUT #migrate" do
      it "changes all references to one library_interactive to another library_interactive and redirects to the library_interactive index" do
        library_interactive1 = LibraryInteractive.create! valid_attributes
        library_interactive2 = LibraryInteractive.create! valid_attributes
        managed_interactive = FactoryBot.create(:managed_interactive, library_interactive: library_interactive1)
        put :migrate, params: { id: library_interactive1.to_param, new_library_interactive_id: library_interactive2.to_param }
        managed_interactive.reload
        expect(response).to redirect_to(library_interactives_url)
        expect(managed_interactive.library_interactive_id).to eq(library_interactive2.id)
      end

      it "changes nothing and redirects to the library_interactive index when the library interactive specified for migration is not used by any managed interactives" do
        library_interactive1 = LibraryInteractive.create! valid_attributes
        library_interactive2 = LibraryInteractive.create! valid_attributes
        managed_interactive = FactoryBot.create(:managed_interactive, library_interactive: library_interactive2)
        put :migrate, params: { id: library_interactive1.to_param, new_library_interactive_id: library_interactive2.to_param }
        managed_interactive.reload
        expect(response).to redirect_to(library_interactives_url)
        expect(managed_interactive.library_interactive_id).to eq(library_interactive2.id)
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested library_interactive" do
        library_interactive = LibraryInteractive.create! valid_attributes
        expect {
          delete :destroy, params: { id: library_interactive.to_param }
        }.to change(LibraryInteractive, :count).by(-1)
      end

      it "redirects to the library_interactives list" do
        library_interactive = LibraryInteractive.create! valid_attributes
        delete :destroy, params: { id: library_interactive.to_param }
        expect(response).to redirect_to(library_interactives_url)
      end
    end
  end

  [:author, :user].each do |user_type|
    describe "as a #{user_type}" do
      before(:each) do
        @user = FactoryBot.create(user_type)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a failure response for HTML requests" do
          LibraryInteractive.create! valid_attributes
          get :index
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "GET #new" do
        it "returns a failure response" do
          get :new
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "GET #edit" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          get :edit, params: { id: library_interactive.to_param }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "POST #create" do
        it "returns a failure response" do
          post :create, params: { library_interactive: valid_attributes }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "PUT #update" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, params: { id: library_interactive.to_param, library_interactive: {name: "new name"} }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "GET #migrate" do
        it "returns a failure response for HTML requests" do
          library_interactive = LibraryInteractive.create! valid_attributes
          get :migrate, params: { id: library_interactive.to_param }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "PUT #migrate" do
        it "returns a failure response" do
          library_interactive1 = LibraryInteractive.create! valid_attributes
          library_interactive2 = LibraryInteractive.create! valid_attributes
          put :migrate, params: { id: library_interactive1.to_param, new_library_interactive_id: library_interactive2.to_param }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "DELETE #destroy" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          delete :destroy, params: { id: library_interactive.to_param }
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end
    end
  end

  describe "for JSON requests" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    describe "as an author" do
      before(:each) do
        @user = FactoryBot.create(:author)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a success response" do
          model = FactoryBot.create(:library_interactive, valid_attributes)
          get :index
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response).to be_successful
          expect(response.body).to eq([model].to_json)
        end
      end
    end

    describe "as a non-admin/author user" do
      before(:each) do
        @user = FactoryBot.create(:user)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a failure response" do
          LibraryInteractive.create! valid_attributes
          get :index
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end
    end
  end

end
