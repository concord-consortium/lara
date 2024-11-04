require 'spec_helper'

def json_response_body
  return JSON.parse(response.body)
end

describe Api::V1::PluginsController do
  let(:plugin_id)    { 400 }
  let(:author_data)  { 'author_data' }
  let(:plugin_scope) { nil }
  let(:author)       { nil }
  let(:activity) { FactoryGirl.create(:activity, user: author) }
  let(:embeddable_plugin) {
    page = FactoryGirl.create(:page)
    activity.pages << page
    embeddable_plugin = FactoryGirl.create(:embeddable_plugin)
    page.add_embeddable(embeddable_plugin)
    embeddable_plugin
  }

  let(:plugin) { FactoryGirl.create(:plugin, id: plugin_id, author_data: author_data, plugin_scope: plugin_scope) }

  before(:each) do
    allow(Plugin).to receive(:find).and_return(plugin)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "When a non-admin/non-author uses a plugin" do
    let(:user) { FactoryGirl.create(:user)}

    describe 'to load author data' do
      it "they should get a not authorized error" do
        post :load_author_data, params: { plugin_id: plugin_id }
        expect(response.status).to eq(403)
      end
    end

    describe 'to save author data' do
      it "they should get a not authorized error" do
        post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
        expect(response.status).to eq(403)
      end
    end
  end

  describe "When an author of an activity they didn't create uses a plugin" do
    let(:user) { FactoryGirl.create(:author)}
    let(:author) { FactoryGirl.create(:author)}

    context 'at the activity level' do
      let(:plugin_scope) { activity }

      describe 'to load author data' do
        it "they should get a not authorized error" do
          post :load_author_data, params: { plugin_id: plugin_id }
          expect(response.status).to eq(403)
        end
      end

      describe 'to save author data' do
        it "they should get a not authorized error" do
          post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
          expect(response.status).to eq(403)
        end
      end
    end

    context 'at the embeddable level' do
      let(:plugin_scope) { embeddable_plugin }

      describe 'to load author data' do
        it "they should get a not authorized error" do
          post :load_author_data, params: { plugin_id: plugin_id }
          expect(response.status).to eq(403)
        end
      end

      describe 'to save author data' do
        it "they should get a not authorized error" do
          post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
          expect(response.status).to eq(403)
        end
      end

    end

  end

  describe "When an author of an activity uses a plugin in that activity" do
    let(:user) { FactoryGirl.create(:author)}
    let(:author) { user }

    context 'at the activity level' do
      let(:plugin_scope) { activity }

      describe 'to load author data' do
        it "they should get the author data" do
          post :load_author_data, params: { plugin_id: plugin_id }
          expect(response.status).to eq(200)
          expect(json_response_body['author_data']).to eq(author_data)
        end
      end

      describe 'to save author data' do
        it "they should save the author data" do
          post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
          expect(response.status).to eq(200)
          expect(json_response_body['author_data']).to eq("new_author_data")
        end
      end
    end

    context 'at the embeddable level' do
      let(:plugin_scope) { embeddable_plugin }

      describe 'to load author data' do
        it "they should get the author data" do
          post :load_author_data, params: { plugin_id: plugin_id }
          expect(response.status).to eq(200)
          expect(json_response_body['author_data']).to eq(author_data)
        end
      end

      describe 'to save author data' do
        it "they should save the author data" do
          post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
          expect(response.status).to eq(200)
          expect(json_response_body['author_data']).to eq("new_author_data")
        end
      end
    end
  end

  describe "When an admin uses a plugin" do
    let (:user) { FactoryGirl.create(:admin) }

    describe 'to load author data' do
      it "they should get the author data" do
        post :load_author_data, params: { plugin_id: plugin_id }
        expect(response.status).to eq(200)
        expect(json_response_body['author_data']).to eq(author_data)
      end
    end

    describe 'to save author data' do
      it "they should save the author data" do
        post :save_author_data, params: { plugin_id: plugin_id, author_data: "new_author_data" }
        expect(response.status).to eq(200)
        expect(json_response_body['author_data']).to eq("new_author_data")
      end
    end
  end
end
