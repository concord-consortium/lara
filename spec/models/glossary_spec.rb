require 'spec_helper'

RSpec.describe Glossary do
  let(:author)        { FactoryGirl.create(:author) }
  let(:glossary)      {
    glossary = FactoryGirl.create(:glossary)
    glossary.user = author
    glossary.json = JSON.generate({
      askForUserDefinition: true,
      autoShowMediaInPopup: true,
      showSideBar: true,
      enableStudentRecording: true,
      enableStudentLanguageSwitching: true,
      definitions: [
        {
          word: "foo",
          definition: "a foo",
          image?: "http://www.example.com/foo.png",
          zoomImage?: "http://www.example.com/foo-zoomed.png",
          video?: "http://www.example.com/foo.mp4",
          imageCaption?: "foo image caption",
          videoCaption?: "foo video caption"
        },
        {
          word: "bar",
          definition: "a bar",
          image?: "http://www.example.com/bar.png",
          zoomImage?: "http://www.example.com/bar-zoomed.png",
          video?: "http://www.example.com/bar.mp4",
          imageCaption?: "bar image caption",
          videoCaption?: "bar video caption"
        }
      ],
      translations: {
        "es": {
          "foo": "una foo",
          "bar": "una bar",
        },
        "fr": {
          "foo": "les foo",
          "bar": "les bar",
        }
      }
    })
    glossary
  }

  it "should generate a json representation of itself" do
    expect(glossary.to_json).to eq({
      "id" => glossary.id,
      "name" => glossary.name,
      "user_id" => glossary.user_id,
      "json" => {
        "askForUserDefinition" => true,
        "autoShowMediaInPopup" => true,
        "showSideBar" => true,
        "enableStudentRecording" => true,
        "enableStudentLanguageSwitching" => true,
        "definitions" => [
          {
            "definition"=>"a foo",
            "image?"=>"http://www.example.com/foo.png",
            "imageCaption?"=>"foo image caption",
            "video?"=>"http://www.example.com/foo.mp4",
            "videoCaption?"=>"foo video caption",
            "word"=>"foo",
            "zoomImage?"=>"http://www.example.com/foo-zoomed.png"
          },
          {
            "definition"=>"a bar",
            "image?"=>"http://www.example.com/bar.png",
            "imageCaption?"=>"bar image caption",
            "video?"=>"http://www.example.com/bar.mp4",
            "videoCaption?"=>"bar video caption",
            "word"=>"bar",
            "zoomImage?"=>"http://www.example.com/bar-zoomed.png"
          }
        ],
        "translations" => {
          "es"=>{
            "bar"=>"una bar", "foo"=>"una foo"
          },
          "fr"=>{
            "bar"=>"les bar", "foo"=>"les foo"
          }
        }
      }
    })
  end
end
