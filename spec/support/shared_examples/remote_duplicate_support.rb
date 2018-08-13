shared_examples "remote duplicate support" do
  describe '#remote_duplicate' do
    describe "when request is coming from normal user (even admin)" do
      before(:each) do
        user = FactoryGirl.create(:admin)
        sign_in user
      end
      it "should return 403 unauthorized" do
        post :remote_duplicate, { :id => resource.id }
        expect(response.status).to be(403)
      end
    end

    describe "when request is coming from peer (trusted Portal)" do
      let(:user) { FactoryGirl.create(:author) }
      let(:secret) { 'very secure secret' }
      let(:portal_url) { 'http://portal.concord.org' }
      let(:portal_name) { 'test portal' }
      let(:fake_portal_struct) { Struct.new(:name, :url, :publishing_url, :secret) }
      let(:fake_portal) { fake_portal_struct.new(portal_name, portal_url, portal_url, secret) }
      let(:user_email) { 'test@email.com' }
      let(:self_url) { "#{request.protocol}#{request.host_with_port}" }
      let(:headers) { { 'Authorization' => "Bearer #{secret}" } }

      before(:each) do
        allow(Concord::AuthPortal).to receive(:all).and_return({ test: fake_portal })
        @request.env['Authorization'] = "Bearer #{secret}"
        resource.user = user
        resource.save
      end

      def make_request
        post :remote_duplicate, id: resource.id, user_email: user_email, add_to_portal: portal_url
      end

      def get_copy
        owner = User.find_by_email(user_email)
        resource.class.where(user_id: owner.id).first
      end

      it "should duplicate resource and return 200 OK + publication data" do
        make_request

        copy = get_copy
        expect(copy).not_to be_nil
        expect(copy.user.email).not_to eq(resource.user.email)
        expect(copy.user.email).to eq(user_email)

        expect(response.status).to be(200)
        expect(JSON.parse(response.body)['publication_data']).to eq(copy.serialize_for_portal(self_url))
      end

      it "should create a new user when necessary" do
        expect(User.find_by_email(user_email)).to be_nil
        make_request
        expect(User.find_by_email(user_email)).not_to be_nil
      end

      it "should create portal publication entry" do
        old_count = PortalPublication.count
        make_request
        expect(PortalPublication.count).to eq(old_count + 1)
        copy = get_copy
        expect(copy.portal_publications.count).to eq(1)
        expect(copy.publication_hash).not_to be_nil
        pub = copy.portal_publications.first
        expect(pub.success).to eq(true)
        expect(pub.sent_data).to eq(copy.serialize_for_portal(self_url).to_json)
      end
    end
  end
end
