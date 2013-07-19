require 'spec_helper'

describe Project do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "Project.default" do
    subject    { Project.default }
    its(:title) { should == Project::DefaultName}
  end
end
