require "spec_helper"

describe Api::V1::GlossariesController do
  let(:author)        { FactoryGirl.create(:author) }
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
  let(:glossary)      {
    glossary = FactoryGirl.create(:glossary)
    glossary.user = author
    glossary.json = stringifed_json
    glossary.save!
    glossary
  }

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

end
