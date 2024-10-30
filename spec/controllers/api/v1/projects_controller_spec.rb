require 'spec_helper'

describe Api::V1::ProjectsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let!(:project1) { FactoryGirl.create(:project, title: "Test Project 1", admins: [user]) }
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
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      expect(parsed_response[:projects]).to include(a_hash_including(id: project1.id, title: project1.title))
      expect(parsed_response[:projects]).to include(a_hash_including(id: project2.id, title: project2.title))
    end
  end

  describe "#show" do
    it "returns a JSON string for a project with a specific ID" do
      xhr :get, "show", {id: project1.id}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq({
        project: project1,
        admins: [{id: user.id, email: user.email}]
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
      admins = project1.admins.map {|a| {id: a.id, email: a.email} }
      xhr :post, "update", {id: project1.id, project: {title: "New Project Title", admins: admins}}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      response_body = JSON.parse(response.body, symbolize_names: true)
      project = response_body[:project]
      expect(project[:title]).to eq("New Project Title")
      expect(project[:updated_at]).not_to eq(prev_updated_at)
      expect(response_body[:admins]).to eq([{id: user.id, email: user.email}])
    end

    it "allows removing project admins" do
      expect(project1.admins.length).to eq(1)
      xhr :post, "update", {id: project1.id, project: {title: "New Project Title", admins: []}}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      response_body = JSON.parse(response.body, symbolize_names: true)
      project = response_body[:project]
      expect(response_body[:admins]).to eq([])
    end

    it "filters out admins that are not already set" do
      admins = project1.admins.map {|a| {id: a.id, email: a.email} }
      admins.push({id: user2.id, email: user2.email})
      xhr :post, "update", {id: project1.id, project: {title: "New Project Title", admins: admins}}
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:admins]).to eq([{id: user.id, email: user.email}])
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
