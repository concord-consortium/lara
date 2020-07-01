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
    activity.save
    activity
  end

  describe "#publish" do
    it "should attempt to publish to the portal" do
      get :publish, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
    end
  end

  describe "#add_portal" do
    let(:activity_hash) do
      {
        "source_type"   => "LARA",
        "type"          =>"Activity",
        "name"          =>"Activity One",
        "description"   =>"Activity One Description",
        "url"           =>"http://test.host/activities/#{act_one.id}",
        "create_url"    =>"http://test.host/activities/#{act_one.id}",
        "author_url"    =>"http://test.host/activities/#{act_one.id}/edit",
        "print_url"     =>"http://test.host/activities/#{act_one.id}/print_blank",
        "student_report_enabled" => act_one.student_report_enabled,
        "show_submit_button" => true,
        "thumbnail_url" =>"thumbnail",
        "author_email"  => @user.email,
        "is_locked"     =>false,
        "sections"      => [
           {"name"  => "Activity One Section",
            "pages" => []
           }
        ]
      }
    end
    let(:good_body) { activity_hash.to_json }
    let(:publishing_url) { "http://foo.bar/publish/v2/blarg"}
    let(:url) { "http://foo.bar/"}
    let(:strategy_name) { "foo_bar"}
    let(:mock_portal) { double(:publishing_url => publishing_url, :url => url, :strategy_name => strategy_name) }
    let(:good_request) {{
      :body => good_body,
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
    it "should set publciation_status to public" do
      get :add_portal, { :publishable_id => act_one.id, :publishable_type => "LightweightActivity" }
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
  end
end
