require 'spec_helper'

describe Api::V1::ProjectsController do
  let!(:project1) { FactoryGirl.create(:project, title: "Test Project 1") }
  let!(:project2) { FactoryGirl.create(:project, title: "Test Project 2") }
  let(:admin) { FactoryGirl.create(:admin) }

  before(:each) do
    sign_in admin
  end

  describe "#index" do
    it "returns a list of available projects" do
      xhr :get, "index"
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq({
        projects: [
          project1,
          project2
        ]
      }.to_json)
    end
  end

  describe "#show" do
    it "returns a JSON string for a project with a specific ID" do
      xhr :get, "show", {id: project1.id}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq({
        project: project1
      }.to_json)
    end
    it "returns a 404 error for a non-existent project ID" do
      xhr :get, "show", {id: 123456789}
      expect(response.status).to eq(404)
    end
  end

  describe "#create" do
    it "returns a success message and values for the newly created project" do
      xhr :post, "create", {project: {title: "My New Project", project_key: "my-new-project"}}
      expect(response.status).to eq(201)
      expect(response.content_type).to eq("application/json")
      response_body = JSON.parse(response.body, symbolize_names: true)
      project = response_body[:project]
      expect(project[:title]).to eq("My New Project")
      expect(project[:project_key]).to eq("my-new-project")
      expect(project[:created_at]).not_to be_nil
      expect(project[:updated_at]).not_to be_nil
    end
  end

  describe "#update" do
    it "returns a success message and a JSON string when a project is updated" do
      prev_updated_at = project1.updated_at
      xhr :post, "update", {project: {id: project1.id, title: "New Project Title"}}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      response_body = JSON.parse(response.body, symbolize_names: true)
      project = response_body[:project]
      expect(project[:title]).to eq("New Project Title")
      expect(project[:updated_at]).not_to eq(prev_updated_at)
    end
  end

  describe "#destroy" do
    it "returns a success message when a project is deleted" do
      xhr :post, "destroy", {id: project1.id}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq({
        success: true
      }.to_json)
    end
  end
end