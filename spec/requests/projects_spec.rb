require 'spec_helper'

describe "Projects" do
  describe "GET /projects" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get projects_path, params: {}, headers: {}
      expect(response.status).to be(403)
    end
  end
end
