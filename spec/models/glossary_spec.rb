require 'spec_helper'

RSpec.describe Glossary do
  let(:author)    { FactoryGirl.create(:author) }
  let(:author2)   { FactoryGirl.create(:author) }
  let(:admin)     { FactoryGirl.create(:admin) }

  let(:glossary)      {
    glossary = FactoryGirl.create(:glossary, name: "Glossary 1", user: author)
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
  let(:glossary2) { FactoryGirl.create(:glossary, name: "Glossary 2", user: author2) }

  describe "should export itself" do
    it "as the author with can_edit as true" do
      expect(glossary.export(author)).to eq({
        id: glossary.id,
        name: glossary.name,
        user_id: glossary.user_id,
        can_edit: true,
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

    it "as an admin with can_edit as true" do
      expect(glossary.export(admin)[:can_edit]).to eq(true)
    end

    it "as not the author or admin with can_edit as false" do
      expect(glossary.export(author2)[:can_edit]).to eq(false)
    end
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

  describe "self.by_others" do
    let(:other_author) { FactoryGirl.create(:author) }

    it "should return an empty array if the user is nil" do
      expect(Glossary.by_others(nil)).to eq([])
    end

    it "should return an array of glossaries by other users if the user is not nil" do
      expect(Glossary.by_others(author)).to eq([glossary2])
    end

    describe "with a different user" do
      it "should return an array of glossaries by the user if the user is not nil" do
        expect(Glossary.by_others(other_author)).to eq([glossary, glossary2])
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
        expect(Glossary.by_others(other_author)).to eq([glossary2, glossary1])
      end
    end
  end

  describe "can_edit" do
    it "should return true for authors of glossaries" do
      expect(glossary.can_edit(author)).to eq(true)
    end
    it "should return true for admins" do
      expect(glossary.can_edit(admin)).to eq(true)
    end
    it "should return false for other users that are not admins" do
      expect(glossary.can_edit(author2)).to eq(false)
    end
  end

  it "should support #to_hash" do
    expect(glossary.to_hash).to eq({
      id: glossary.id,
      name: glossary.name,
      user_id: glossary.user_id,
      json: glossary.json
    })
  end

  it "should support #to_export_hash" do
    expect(glossary.to_export_hash).to eq({
      id: glossary.id,
      name: glossary.name,
      user_id: glossary.user_id,
      json: glossary.json,
      type: "Glossary"
    })
  end

  it "should support #duplicate" do
    expect(glossary.duplicate(author2).to_hash).to eq({
      id: nil,
      name: "Copy of #{glossary.name}",
      user_id: author2.id,
      json: glossary.json
    })
  end

  it "should support #self.import" do
    imported_glossary = Glossary.import(glossary.to_export_hash, author2)
    expect(imported_glossary.id).not_to eq(glossary.id)
    expect(imported_glossary.user).to eq(author2)
  end

  it "should support #self.extract_from_hash" do
    expect(Glossary.extract_from_hash(glossary.to_export_hash)).to eq({
      name: glossary.name,
      json: glossary.json
    })
  end

  describe "homepage index methods" do
    describe "as an author" do
      it "should support self.my" do
        expect(Glossary.my(author)).to eq([glossary])
      end

      it "should support self.can_see" do
        expect(Glossary.can_see(author)).to eq([glossary, glossary2])
      end

      it "should support self.visible" do
        expect(Glossary.visible(author)).to eq([glossary, glossary2])
      end

      it "should support self.search" do
        expect(Glossary.search("Glossary", author)).to eq([glossary, glossary2])
      end

      it "should support self.public_for_user" do
        expect(Glossary.public_for_user(author)).to eq([glossary, glossary2])
      end
    end

    describe "as an admin" do
      before(:each) do
        # make sure both glossaries are visible in a query
        glossary
        glossary2
      end

      it "should support self.my" do
        expect(Glossary.my(admin)).to eq([])
      end

      it "should support self.can_see" do
        expect(Glossary.can_see(admin)).to eq([glossary, glossary2])
      end

      it "should support self.visible" do
        expect(Glossary.visible(admin)).to eq([glossary, glossary2])
      end

      it "should support self.search" do
        expect(Glossary.search("Glossary", admin)).to eq([glossary, glossary2])
      end

      it "should support self.public_for_user" do
        expect(Glossary.public_for_user(author)).to eq([glossary, glossary2])
      end
    end
  end

  describe "scopes" do
    it "should support none" do
      expect(Glossary.none).to eq ([])
    end

    it "should support newest" do
      expect(Glossary.newest).to eq ([glossary2, glossary])
    end
  end

  describe "self.get_glossary_approved_script" do
    it "should return nil with no glossary approved script" do
      expect(Glossary.get_glossary_approved_script).to eq nil
    end

    describe "with glossary approved scripts" do
      let(:approved_script1) { FactoryGirl.create(:approved_script, label: "glossary") }
      let(:approved_script2) { FactoryGirl.create(:approved_script, label: "glossary") }

      before :each do
        approved_script1
        approved_script2
      end

      it "should return the first glossary approved script if no setting is set" do
        expect(Glossary.get_glossary_approved_script).to eq approved_script1
      end

      describe "with glossary approved script setting" do
        let(:glossary_setting) { FactoryGirl.create(:setting, key: "glossary_approved_script_id", value: "#{approved_script2.id}") }

        it "should return the glossary approved in the settings" do
          glossary_setting
          expect(Glossary.get_glossary_approved_script).to eq approved_script2
        end
      end
    end
  end

end
