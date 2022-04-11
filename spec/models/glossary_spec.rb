require 'spec_helper'

RSpec.describe Glossary do
  let(:author)        { FactoryGirl.create(:author) }
  let(:glossary)      {
    glossary = FactoryGirl.create(:glossary, user: author)
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
    glossary.save!
    glossary
  }

  it "should export itself" do
    expect(glossary.export).to eq({
      id: glossary.id,
      name: glossary.name,
      user_id: glossary.user_id,
      json: {
        askForUserDefinition: true,
        autoShowMediaInPopup: true,
        showSideBar: true,
        enableStudentRecording: true,
        enableStudentLanguageSwitching: true,
        definitions: [
          {
            definition: "a foo",
            image: "http://www.example.com/foo.png",
            imageCaption: "foo image caption",
            video: "http://www.example.com/foo.mp4",
            videoCaption: "foo video caption",
            word: "foo",
            zoomImage: "http://www.example.com/foo-zoomed.png"
          },
          {
            definition: "a bar",
            image: "http://www.example.com/bar.png",
            imageCaption: "bar image caption",
            video: "http://www.example.com/bar.mp4",
            videoCaption: "bar video caption",
            word: "bar",
            zoomImage: "http://www.example.com/bar-zoomed.png"
          }
        ],
        translations: {
          es: {
            bar: "una bar",
            foo: "una foo"
          },
          fr: {
            bar: "les bar",
            foo: "les foo"
          }
        }
      }
    })
  end

  it "should export only the json member" do
    expect(glossary.export_json_only).to eq({
      askForUserDefinition: true,
      autoShowMediaInPopup: true,
      showSideBar: true,
      enableStudentRecording: true,
      enableStudentLanguageSwitching: true,
      definitions: [
        {
          definition: "a foo",
          image: "http://www.example.com/foo.png",
          imageCaption: "foo image caption",
          video: "http://www.example.com/foo.mp4",
          videoCaption: "foo video caption",
          word: "foo",
          zoomImage: "http://www.example.com/foo-zoomed.png"
        },
        {
          definition: "a bar",
          image: "http://www.example.com/bar.png",
          imageCaption: "bar image caption",
          video: "http://www.example.com/bar.mp4",
          videoCaption: "bar video caption",
          word: "bar",
          zoomImage: "http://www.example.com/bar-zoomed.png"
        }
      ],
      translations: {
        es: {
          bar: "una bar",
          foo: "una foo"
        },
        fr: {
          bar: "les bar",
          foo: "les foo"
        }
      }
    })
  end

  describe "self.by_author" do
    it "should return an empty array if the user is nil" do
      expect(Glossary.by_author(nil)).to eq([])
    end

    it "should return an array of glossaries by the user if the user is not nil" do
      expect(Glossary.by_author(author)).to eq([glossary])
    end

    describe "with a different user" do
      let(:other_author) { FactoryGirl.create(:author) }

      it "should return an array of glossaries by the user if the user is not nil" do
        expect(Glossary.by_author(other_author)).to eq([])
      end
    end

    describe "with multiple glossaries" do
      let(:glossary1)      {
        glossary = FactoryGirl.create(:glossary, user: author, name: "ZZZ")
        glossary.save!
        glossary
      }
      let(:glossary2)      {
        glossary = FactoryGirl.create(:glossary, user: author, name: "AAA")
        glossary.save!
        glossary
      }

      it "returns the list in alpha order" do
        expect(Glossary.by_author(author)).to eq([glossary2, glossary1])
      end
    end
  end
end
