require 'spec_helper'

RSpec.describe Rubric do
  let(:author)    { FactoryBot.create(:author) }
  let(:author2)   { FactoryBot.create(:author) }
  let(:admin)     { FactoryBot.create(:admin) }
  let(:project)     { FactoryBot.create(:project) }

  let(:rubric)      {
    rubric = FactoryBot.create(:rubric, name: "Rubric 1", user: author, project: project, doc_url: "https://example.com")
    rubric.save!
    rubric.update_column(:updated_at, 1.day.ago)
    rubric
  }
  let(:rubric2) { 
    rubric = FactoryBot.create(:rubric, name: "Rubric 2", user: author2)
    rubric.update_column(:updated_at, Time.now)
    rubric
  }

  describe "should export itself" do
    it "as the author with can_edit as true" do
      expect(rubric.export(author)).to eq({
        id: rubric.id,
        name: rubric.name,
        doc_url: rubric.doc_url,
        project: project.export(),
        user_id: rubric.user_id,
        can_edit: true
      })
    end

    it "as an admin with can_edit as true" do
      expect(rubric.export(admin)[:can_edit]).to eq(true)
    end

    it "as not the author or admin with can_edit as false" do
      expect(rubric.export(author2)[:can_edit]).to eq(false)
    end

  end

  describe "self.by_author" do
    it "should return an empty array if the user is nil" do
      expect(Rubric.by_author(nil)).to eq([])
    end

    it "should return an array of rubrics by the user if the user is not nil" do
      expect(Rubric.by_author(author)).to eq([rubric])
    end

    describe "with a different user" do
      let(:other_author) { FactoryBot.create(:author) }

      it "should return an array of rubrics by the user if the user is not nil" do
        expect(Rubric.by_author(other_author)).to eq([])
      end
    end

    describe "with multiple rubrics" do
      let(:rubric1)      {
        rubric = FactoryBot.create(:rubric, user: author, name: "ZZZ")
        rubric.save!
        rubric
      }
      let(:rubric2)      {
        rubric = FactoryBot.create(:rubric, user: author, name: "AAA")
        rubric.save!
        rubric
      }

      it "returns the list in alpha order" do
        expect(Rubric.by_author(author)).to eq([rubric2, rubric1])
      end
    end
  end

  describe "self.by_others" do
    let(:other_author) { FactoryBot.create(:author) }

    it "should return an empty array if the user is nil" do
      expect(Rubric.by_others(nil)).to eq([])
    end

    it "should return an array of rubrics by other users if the user is not nil" do
      expect(Rubric.by_others(author)).to eq([rubric2])
    end

    describe "with a different user" do
      it "should return an array of rubrics by the user if the user is not nil" do
        expect(Rubric.by_others(other_author)).to eq([rubric, rubric2])
      end
    end

    describe "with multiple rubrics" do
      let(:rubric1)      {
        rubric = FactoryBot.create(:rubric, user: author, name: "ZZZ")
        rubric.save!
        rubric
      }
      let(:rubric2)      {
        rubric = FactoryBot.create(:rubric, user: author, name: "AAA")
        rubric.save!
        rubric
      }

      it "returns the list in alpha order" do
        expect(Rubric.by_others(other_author)).to eq([rubric2, rubric1])
      end
    end
  end

  describe "can_edit" do
    it "should return true for authors of rubrics" do
      expect(rubric.can_edit(author)).to eq(true)
    end
    it "should return true for admins" do
      expect(rubric.can_edit(admin)).to eq(true)
    end
    it "should return false for other users that are not admins" do
      expect(rubric.can_edit(author2)).to eq(false)
    end
  end

  it "should support #to_hash" do
    expect(rubric.to_hash).to eq({
      id: rubric.id,
      name: rubric.name,
      doc_url: rubric.doc_url,
      project: rubric.project,
      user_id: rubric.user_id
    })
  end

  it "should support #to_export_hash" do
    expect(rubric.to_export_hash).to eq({
      id: rubric.id,
      name: rubric.name,
      doc_url: rubric.doc_url,
      project: rubric.project,
      user_id: rubric.user_id,
      type: "Rubric"
    })
  end

  it "should support #duplicate" do
    duplicated_rubric_hash = rubric.duplicate(author2).to_hash
    expect(duplicated_rubric_hash).to include(
      name: "Copy of #{rubric.name}",
      doc_url: rubric.doc_url,
      project: rubric.project,
      user_id: author2.id
    )
  end

  it "should support #self.import" do
    imported_rubric = Rubric.import(rubric.to_export_hash, author2)
    expect(imported_rubric.id).not_to eq(rubric.id)
    expect(imported_rubric.user).to eq(author2)
    expect(imported_rubric.project.id).to eq(project.id)
  end

  it "should support #self.extract_from_hash" do
    expect(Rubric.extract_from_hash(rubric.to_export_hash)).to eq({
      name: rubric.name
    })
  end

  describe "homepage index methods" do
    describe "as an author" do
      it "should support self.my" do
        expect(Rubric.my(author)).to eq([rubric])
      end

      it "should support self.can_see" do
        expect(Rubric.can_see(author)).to eq([rubric, rubric2])
      end

      it "should support self.visible" do
        expect(Rubric.visible(author)).to eq([rubric, rubric2])
      end

      it "should support self.search" do
        expect(Rubric.search("Rubric", author)).to eq([rubric, rubric2])
      end

      it "should support self.public_for_user" do
        expect(Rubric.public_for_user(author)).to eq([rubric, rubric2])
      end
    end

    describe "as an admin" do
      before(:each) do
        # make sure both rubrics are visible in a query
        rubric
        rubric2
      end

      it "should support self.my" do
        expect(Rubric.my(admin)).to eq([])
      end

      it "should support self.can_see" do
        expect(Rubric.can_see(admin)).to eq([rubric, rubric2])
      end

      it "should support self.visible" do
        expect(Rubric.visible(admin)).to eq([rubric, rubric2])
      end

      it "should support self.search" do
        expect(Rubric.search("Rubric", admin)).to eq([rubric, rubric2])
      end

      it "should support self.public_for_user" do
        expect(Rubric.public_for_user(author)).to eq([rubric, rubric2])
      end
    end
  end

  describe "scopes" do
    it "should support no_rubrics" do
      expect(Rubric.no_rubrics).to eq ([])
    end

    it "should support newest" do
      expect(Rubric.newest).to eq ([rubric2, rubric])
    end
  end

end
