require "spec_helper"

describe Api::V1::GlossariesController do
  let(:author)        { FactoryGirl.create(:author) }
  let(:author2)       { FactoryGirl.create(:author) }
  let(:stringifed_json) {
    JSON.generate({
      askForUserDefinition: true,
      autoShowMediaInPopup: true,
      showSideBar: true,
      enableStudentRecording: true,
      enableStudentLanguageSwitching: true,
      definitions: [
        {
          word: "foo",
          definition: "a foo",
          image: "http://www.example.com/foo.png",
          zoomImage: "http://www.example.com/foo-zoomed.png",
          video: "http://www.example.com/foo.mp4",
          imageCaption: "foo image caption",
          videoCaption: "foo video caption"
        },
        {
          word: "bar",
          definition: "a bar",
          image: "http://www.example.com/bar.png",
          zoomImage: "http://www.example.com/bar-zoomed.png",
          video: "http://www.example.com/bar.mp4",
          imageCaption: "bar image caption",
          videoCaption: "bar video caption"
        }
      ],
      translations: {
        es: {
          foo: "una foo",
          bar: "una bar",
        },
        fr: {
          foo: "les foo",
          bar: "les bar",
        }
      }
    })
  }
  let(:glossary) { FactoryGirl.create(:glossary, name: "Glossary", user: author, json: stringifed_json) }

  describe "#show" do
    it "recognizes and generates #show" do
      expect({:get => "api/v1/glossaries/#{glossary.id}.json"}).to route_to(
        :controller => "api/v1/glossaries",
        :action => "show",
        :id => "#{glossary.id}",
        :format => "json"
      )
    end

    it "when user is anonymous, shows an glossary's full json" do
      get :show, :id => glossary.id, :format => :json

      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({
        id: glossary.id,
        name: glossary.name,
        user_id: glossary.user_id,
        can_edit: false,
        json: JSON.parse(stringifed_json)
      }.as_json)
    end

    it "when user is anonymous, shows an glossary's json contents" do
      get :show, :id => glossary.id, :format => :json, :json_only => true

      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq(JSON.parse(stringifed_json))
    end
  end

  describe "#update" do
    it "when user is anonymous, updates are not allowed" do
      post :update, :id => glossary.id, :name => "Updated Glossary", :format => :json

      expect(response.status).to eq(403)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({
        message: "Not authorized",
        response_type: "ERROR"
      }.as_json)
    end

    it "when user did not create the glossary, updates are not allowed" do
      sign_in author2
      post :update, :id => glossary.id, :name => "Updated Glossary", :format => :json

      expect(response.status).to eq(403)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({
        message: "Not authorized",
        response_type: "ERROR"
      }.as_json)
    end

    describe "when user did create the glossary, " do
      let(:updated_name) { "Updated Glossary" }
      let(:updated_json) { {foo: "bar"} }
      let(:updated_stringified_json) { JSON.generate(updated_json) }

      before(:each) do
        sign_in author
      end

      it "updates to a blank name are not allowed" do
        post :update, :id => glossary.id, :name => "", :format => :json

        expect(response.status).to eq(500)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          message: "Validation failed: Name can't be blank",
          response_type: "ERROR"
        }.as_json)
      end

      it "updates to just the name are allowed" do
        post :update, :id => glossary.id, :name => updated_name, :format => :json

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          id: glossary.id,
          name: updated_name,
          json: glossary.export_json_only
        }.as_json)
      end

      it "updates to just the json as a string are allowed" do
        post :update, :id => glossary.id, :json => updated_stringified_json, :format => :json

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          id: glossary.id,
          name: glossary.name,
          json: updated_json
        }.as_json)
      end

      it "updates to just the json as an object are allowed" do
        post :update, :id => glossary.id, :json => updated_json, :format => :json

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          id: glossary.id,
          name: glossary.name,
          json: updated_json
        }.as_json)
      end

      it "updates to both name and json are allowed" do
        post :update, :id => glossary.id, :name => updated_name, :json => updated_stringified_json, :format => :json

        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          id: glossary.id,
          name: updated_name,
          json: updated_json
        }.as_json)
      end
    end
  end
end