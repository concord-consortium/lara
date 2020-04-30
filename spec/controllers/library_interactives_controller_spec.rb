require 'spec_helper'

describe LibraryInteractivesController do

  let(:valid_attributes) {
    {
      :aspect_ratio_method => "DEFAULT",
      :authoring_guidance => "valid authoring_guidance",
      :base_url => "http://example.com/",
      :click_to_play => false,
      :click_to_play_prompt => "valid click_to_play_prompt",
      :description => "valid description",
      :enable_learner_state => false,
      :full_window => false,
      :has_report_url => false,
      :image_url => "http://example.com/image_url.jpg",
      :name => "valid name",
      :native_height => 100,
      :native_width => 200,
      :no_snapshots => false,
      :show_delete_data_button => false,
      :thumbnail_url => "http://example.com/thumbnail_url.jpg"
    }
  }

  let(:invalid_attributes) {
    {
      :base_url => "does not start with protocol",
      :native_height => "invalid",
      :native_width => "invalid",
    }
  }

  describe "as as admin" do
    before(:each) do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    describe "GET #index" do
      it "returns a success response" do
        LibraryInteractive.create! valid_attributes
        get :index, {}
        expect(response).to be_successful
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new, {}
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        library_interactive = LibraryInteractive.create! valid_attributes
        get :edit, {:id => library_interactive.to_param}
        expect(response).to be_successful
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new LibraryInteractive" do
          expect {
            post :create, {:library_interactive => valid_attributes}
          }.to change(LibraryInteractive, :count).by(1)
        end

        it "redirects to the library_interactive index" do
          post :create, {:library_interactive => valid_attributes}
          expect(response).to redirect_to(library_interactives_url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, {:library_interactive => invalid_attributes}
          expect(response).to be_successful
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          {:name => "new name"}
        }

        it "updates the requested library_interactive" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, {:id => library_interactive.to_param, :library_interactive => new_attributes}
          library_interactive.reload
          expect(library_interactive.name).to eq("new name")
        end

        it "redirects to the library_interactive index" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, {:id => library_interactive.to_param, :library_interactive => valid_attributes}
          expect(response).to redirect_to(library_interactives_url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, {:id => library_interactive.to_param, :library_interactive => invalid_attributes}
          expect(response).to be_successful
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested library_interactive" do
        library_interactive = LibraryInteractive.create! valid_attributes
        expect {
          delete :destroy, {:id => library_interactive.to_param}
        }.to change(LibraryInteractive, :count).by(-1)
      end

      it "redirects to the library_interactives list" do
        library_interactive = LibraryInteractive.create! valid_attributes
        delete :destroy, {:id => library_interactive.to_param}
        expect(response).to redirect_to(library_interactives_url)
      end
    end
  end

  [:author, :user].each do |user_type|
    describe "as a #{user_type}" do
      before(:each) do
        @user = FactoryGirl.create(user_type)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a failure response for HTML requests" do
          LibraryInteractive.create! valid_attributes
          get :index, {}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "GET #new" do
        it "returns a failure response" do
          get :new, {}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "GET #edit" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          get :edit, {:id => library_interactive.to_param}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "POST #create" do
        it "returns a failure response" do
          post :create, {:library_interactive => valid_attributes}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "PUT #update" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          put :update, {:id => library_interactive.to_param, :library_interactive => {:name => "new name"}}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end

      describe "DELETE #destroy" do
        it "returns a failure response" do
          library_interactive = LibraryInteractive.create! valid_attributes
          delete :destroy, {:id => library_interactive.to_param}
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
        @user = FactoryGirl.create(:author)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a success response" do
          model = LibraryInteractive.create! valid_attributes
          get :index, {}
          expect(response.content_type).to eq("application/json")
          expect(response).to be_successful
          expect(response.body).to eq([model].to_json)
        end
      end
    end

    describe "as a non-admin/author user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "GET #index" do
        it "returns a failure response" do
          LibraryInteractive.create! valid_attributes
          get :index, {}
          expect(response).not_to be_successful
          expect(response).to have_http_status(403)
        end
      end
    end
  end

end
