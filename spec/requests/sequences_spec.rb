require 'spec_helper'

describe "Sequences" do
  describe "GET /sequences" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get sequences_path, params: {}, headers: {}
      expect(response.status).to be(200)
    end
  end
end
