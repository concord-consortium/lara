require 'spec_helper'

describe Project do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "Project.default" do
    before(:each) do
      Project.destroy_all
      @existant = Project.send(:create_default)
    end

    describe "When the default Project doesn't exist" do
      it "should create a new default Project" do
        expect(Project).to receive(:find_by_title).and_return(nil)
        default = Project.default
        expect(default.title).to eq(Project::DefaultName)
        expect(default).not_to eq(@existant)
      end
    end

    describe "When the default Project already exists" do
      it "should use the one the existing default project" do
        expect(Project.default).to eq(@existant)
      end
    end
  end

  describe "Project.export" do
    it "exports project data" do
      project_params = {
        about: "Some text about the project.",
        collaborators: "This is some text about collaborators.",
        collaborators_image_url: "https://static.concord.org/images/collaborators-logos.png",
        contact_email: "test.project@concord.org",
        copyright: "This is some text about copyright.",
        copyright_image_url: "https://static.concord.org/images/cc-license-1.png",
        footer: "Copyright information and such.",
        funders_image_url: "https://static.concord.org/images/funder-logos.png",
        logo_ap: "https://static.concord.org/projects/logos/ap/project-1.png",
        logo_lara: "https://static.concord.org/projects/logos/lara/project-1.png",
        project_key: "test-project-1",
        title: "Test Project 1",
        url: "https://concord.org/projects/test-project-1/"
      }
      project = Project.create(project_params)

      project_params.each do |key, value|
        expect(project.export[key.to_s]).to eq(value)
      end
    end
  end

  describe "Project.find_or_create" do
    it "finds a project when it exists" do
      Project.send(:create_default)
      project_data = {project_key: "default-project", title: "Default Project"}
      project = Project.find_or_create(project_data)
      expect(project).to be_a(Project)
      expect(project.project_key).to eq("default-project")
    end

    it "creates a project when it does not exist" do
      project_data = {project_key: "new-project", title: "New Project"}
      new_project = Project.find_or_create(project_data)
      expect(new_project).to be_a(Project)
      expect(new_project.project_key).to eq("new-project")
    end
  end

  describe "project_admins and admins" do
    let(:project) { FactoryBot.create(:project) }
    let(:user1) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user) }

    it "should be empty by default" do
      expect(project.admins.length).to be(0)
      expect(project.project_admins.length).to be(0)
    end

    it "should return an array when set" do
      project.admins = [user1, user2]
      expect(project.project_admins.length).to be(2)
      expect(project.project_admins[0].project.id).to be(project.id)
      expect(project.project_admins[1].project.id).to be(project.id)
      expect(project.project_admins[0].user.id).to be(user1.id)
      expect(project.project_admins[1].user.id).to be(user2.id)

      expect(project.admins.length).to be(2)
      expect(project.admins[0].id).to be(user1.id)
      expect(project.admins[1].id).to be(user2.id)
    end
  end
end
