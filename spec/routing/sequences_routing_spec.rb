require "spec_helper"

describe SequencesController do
  describe "routing" do

    it "routes to #index" do
      get("/sequences").should route_to("sequences#index")
    end

    it "routes to #new" do
      get("/sequences/new").should route_to("sequences#new")
    end

    it "routes to #show" do
      get("/sequences/1").should route_to("sequences#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sequences/1/edit").should route_to("sequences#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sequences").should route_to("sequences#create")
    end

    it "routes to #update" do
      put("/sequences/1").should route_to("sequences#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sequences/1").should route_to("sequences#destroy", :id => "1")
    end

  end
end
