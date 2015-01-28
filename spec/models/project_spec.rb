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
end
