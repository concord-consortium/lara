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
        footer: "Copyright information and such.",
        help: "Help text for the project.",
        logo_ap: "https://static.concord.org/projects/logos/ap/project-1.png",
        logo_lara: "https://static.concord.org/projects/logos/lara/project-1.png",
        project_key: "test-project-1",
        title: "Test Project 1",
        url: "https://concord.org/projects/test-project-1/"
      }
      project = Project.create(project_params)
      expect(project.export.to_json).to eq(project_params.to_json)
    end
  end

  describe "Project.find_or_create" do
    project_data = {project_key: "default-project", title: "Default Project"}
    it "finds a project when it exists" do
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
end
