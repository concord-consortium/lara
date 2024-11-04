require "spec_helper"

describe LibraryInteractivesController do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/library_interactives").to route_to("library_interactives#index")
    end

    it "routes to #new" do
      expect(get: "/library_interactives/new").to route_to("library_interactives#new")
    end

    it "routes to #edit" do
      expect(get: "/library_interactives/1/edit").to route_to("library_interactives#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/library_interactives").to route_to("library_interactives#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/library_interactives/1").to route_to("library_interactives#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/library_interactives/1").to route_to("library_interactives#destroy", id: "1")
    end
  end
end
