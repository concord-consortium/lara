require "spec_helper"

describe Api::V1::AuthoredContentsController do
  let(:author1) { FactoryGirl.create(:author) }
  let(:author2) { FactoryGirl.create(:author) }

  let(:admin)   { FactoryGirl.create(:admin) }

  let(:project_admin1) { FactoryGirl.create(:user) }
  let(:project_admin2) { FactoryGirl.create(:user) }
  let!(:project1)      { FactoryGirl.create(:project, title: "Test Project 1", admins: [project_admin1]) }
  let!(:project2)      { FactoryGirl.create(:project, title: "Test Project 2", admins: [project_admin2]) }

  let(:rubric)           { FactoryGirl.create(:rubric, user: author1, name: "Rubric 1", project: project1) }
  let(:authored_content) { FactoryGirl.create(:authored_content, user: author1, container: rubric, content_type: "application/json", url: "https://example.com/1") }

  describe "#show" do
    it "recognizes and generates #show" do
      expect({get: "api/v1/authored_contents/#{authored_content.id}"}).to route_to(
        controller: "api/v1/authored_contents",
        action: "show",
        id: "#{authored_content.id}"
      )
    end

    it "returns content type and url" do
      get :show, params: { id: authored_content.id, format: :json }

      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({
        id: authored_content.id,
        content_type: authored_content.content_type,
        url: authored_content.url
      }.as_json)
    end
  end

  context "using S3" do
    before(:each) do
      allow(controller).to receive(:get_s3_config).and_return({
        access_key_id: "foo",
        secret_access_key: "bar",
        bucket_name: "test_bucket",
        source: "test_source"
      })
      allow(controller).to receive(:s3_put).and_return(nil)
    end

    describe "#update" do
      it "when user is anonymous, updates are not allowed" do
        post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

        expect(response.status).to eq(403)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          message: "Not authorized",
          response_type: "ERROR"
        }.as_json)
      end

      it "when user did not create the authored content, updates are not allowed" do
        sign_in author2
        post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

        expect(response.status).to eq(403)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          message: "Not authorized",
          response_type: "ERROR"
        }.as_json)
      end

      describe "when user did create the authored content, " do
        it "it updates" do
          initial_url = "https://example.com/1"
          updated_url = "https://test_bucket.s3.amazonaws.com/lara-authored-content/test_source/rubrics/#{authored_content.container.id}/#{authored_content.id}"

          expect(authored_content.url).to eq(initial_url)

          sign_in author1
          post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          expect(json_response).to eq({
            id: authored_content.id,
            content_type: authored_content.content_type,
            url: updated_url
          }.as_json)

          authored_content.reload
          expect(authored_content.url).to eq(updated_url)
        end
      end

      describe "when the user is an admin, " do
        it "it updates" do
          sign_in admin
          post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

          expect(response.status).to eq(200)
        end
      end

      describe "when the user is a project admin of the container, " do
        it "it updates" do
          sign_in project_admin1
          post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

          expect(response.status).to eq(200)
        end
      end

      describe "when the user is a project admin BUT NOT of the container, " do
        it "it updates" do
          sign_in project_admin2
          post :update, params: { :id => authored_content.id, :format => :json, 'RAW_POST_DATA' => 'test' }

          expect(response.status).to eq(403)
          json_response = JSON.parse(response.body)
          expect(json_response).to eq({
            message: "Not authorized",
            response_type: "ERROR"
          }.as_json)
        end
      end
    end
  end
end
