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
        Project.should_receive(:find_by_title).and_return(nil)
        default = Project.default
        default.title.should == Project::DefaultName
        default.should_not == @existant
      end
    end

    describe "When the default Project already exists" do
      it "should use the one the existing default project" do
        Project.default.should == @existant
      end
    end
  end
end
