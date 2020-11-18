require 'spec_helper'
describe PublicationsController do
  let(:act) { FactoryGirl.create(:public_activity) }
  let(:private_act) { FactoryGirl.create(:activity)}
  let(:ar)  { FactoryGirl.create(:run, :activity_id => act.id) }
  let(:page) { act.pages.create!(:name => "Page 1") }
  let(:sequence) { FactoryGirl.create(:sequence) }

  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe 'routing' do
    it 'recognizes and generates #show_status' do
      expect({:get => "/publications/show_status/LightweigthActivity/3"}).
        to route_to({
          :controller       => 'publications',
          :action           => 'show_status',
          :publishable_type => 'LightweigthActivity',
          :publishable_id   => "3"
      })
    end
  end

  let(:act_one) do
    activity = LightweightActivity.create!({
      :name => 'Activity One',
      :description => 'Activity One Description',
      :publication_status => 'public',
      :thumbnail_url    => 'thumbnail',
    })
    activity.user = @user
    activity.runtime = "LARA"
    activity.save
    activity
  end

  let(:act_two) do
    activity = LightweightActivity.create!({
      :name => 'Activity Two',
      :description => 'Activity Two Description',
      :publication_status => 'public',
      :thumbnail_url    => 'thumbnail',
    })
    activity.user = @user
    activity.runtime = "Activity Player"
    activity.save
    activity
  end

  describe "#publish" do
    it "should attempt to publish to the portal" do
      get :publish, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      get :publish, { :publishable_id => act_two.id, :publishable_type => "LightweightActivity" }
    end
  end

  describe "#add_portal" do
    let(:activity_hash) do
      {
        "type"          =>"Activity",
        "name"          =>"Activity One",
        "author_url"    =>"http://test.host/activities/#{act_one.id}/edit",
        "print_url"     =>"http://test.host/activities/#{act_one.id}/print_blank",
        "student_report_enabled" => act_one.student_report_enabled,
        "show_submit_button" => true,
        "thumbnail_url" =>"thumbnail",
        "is_locked"     =>false,
        "url"           =>"http://test.host/activities/#{act_one.id}",
        "source_type"   => "LARA",
        "tool_id"       =>"",
        "append_auth_token" => false,
        "create_url"    =>"http://test.host/activities/#{act_one.id}",
        "author_email"  => @user.email,
        "description"   =>"Activity One Description",
        "sections"      => [
           {"name"  => "Activity One Section",
            "pages" => []
           }
        ]
      }
    end
    let(:ap_activity_hash) do
      {
        "type"          =>"Activity",
        "name"          =>"Activity Two",
        "author_url"    =>"http://test.host/activities/#{act_two.id}/edit",
        "print_url"     =>"http://test.host/activities/#{act_two.id}/print_blank",
        "student_report_enabled" => act_two.student_report_enabled,
        "show_submit_button" => true,
        "thumbnail_url" =>"thumbnail",
        "is_locked"     =>false,
        "url"           =>"#{ENV["ACTIVITY_PLAYER_URL"]}?activity=http://test.host/api/v1/activities/#{act_two.id}.json",
        "source_type"   => "Activity Player",
        "tool_id"       => ENV['ACTIVITY_PLAYER_URL'],
        "append_auth_token" => true
      }
    end
    let(:good_body) { activity_hash.to_json }
    let(:ap_good_body) { ap_activity_hash.to_json }
    let(:publishing_url) { "http://foo.bar/publish/v2/blarg"}
    let(:activity_player_publishing_url) { "http://foo.bar/api/v1/external_activities/blarg" }
    let(:url) { "http://foo.bar/"}
    let(:strategy_name) { "foo_bar"}
    let(:mock_portal) { double(:publishing_url => publishing_url, :activity_player_publishing_url => activity_player_publishing_url, :url => url, :strategy_name => strategy_name) }
    let(:good_request) {{
      :body => good_body,
      :headers => {'Authorization'=>'Bearer', 'Content-Type'=>'application/json'}
    }}
    let(:ap_good_request) {{
      :body => ap_good_body,
      :headers => {'Authorization'=>'Bearer', 'Content-Type'=>'application/json'}
    }}
    let(:good_response)   { {:status => 201, :body => "", :headers => {} }}
    let(:portal_response) { good_response }

    before(:each) do
      # @url = controller.portal_url
      # stub_request(:post, @url)
      allow(controller).to receive(:find_portal).and_return mock_portal
      allow(LightweightActivity).to receive(:find).and_return act_one
      stub_request(:post, publishing_url).
        with(good_request).
        to_return(portal_response)
      stub_request(:post, activity_player_publishing_url).
        with(ap_good_request).
        to_return(portal_response)
    end



    it "should have proper routing" do
      expect({:get => "/publications/add/LightweightActivity/1"}).
        to route_to({
          :controller       => 'publications',
          :action           => 'add_portal',
          :publishable_type => 'LightweightActivity',
          :publishable_id   => "1"
      })
    end

    it "should call 'portal_publish' on the activity" do
      expect(act_one).to receive(:portal_publish).with(@user, mock_portal, "#{request.protocol}#{request.host_with_port}")
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      # should be moved to publishable_spec
      # expect(act_one.publication_status).to eq('public')
    end

    # this should be moved to publishable_spec
    it "should set publication_status to public" do
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      get :add_portal, { :publishable_id => act_two.id, :publishable_type => "LightweightActivity" }
      # expect(act_one.publication_status).to eq('public')
    end

    # this should be moved to publishable_spec
    it "should attempt to publish to the correct portal endpoint" do
      skip "New portal configurations, more testing here"
      expect(@url).to eq("#{ENV['CONCORD_PORTAL_URL']}/external_activities/publish/v2")
    end

    # this should be moved to publishable_spec
    it 'creates a new PortalPublication record' do
      old_publication_count = act_one.portal_publications.length
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
      expect(act_one.reload.portal_publications.length).to eq(old_publication_count + 1)
    end

    it "should call 'portal_publish' on the activity player runtime activity" do
      expect(act_two).to receive(:portal_publish).with(@user, mock_portal, "#{request.protocol}#{request.host_with_port}")
      get :add_portal, { :publishable_id => act_two.id, :publishable_type => "LightweightActivity" }
      # should be moved to publishable_spec
      # expect(act_two.publication_status).to eq('public')
    end

    it 'creates a new PortalPublication record' do
      old_publication_count = act_two.portal_publications.length
      get :add_portal, { :publishable_id => act_two.id, :publishable_type => "LightweightActivity" }
      expect(act_two.reload.portal_publications.length).to eq(old_publication_count + 1)
    end
  end
end
