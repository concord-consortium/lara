require 'spec_helper'
require "cancan/matchers"

describe User do
  # In production these would be defined in config/app_environment_variables.rb
  ENV['SSO_CLIENT_ID']                      ||= 'localhost'
  ENV['CONFIGURED_PORTALS']                 ||= 'LOCAL CONCORD_PORTAL' # First one is default
  ENV['CONCORD_LOCAL_URL']                  ||= 'http://localhost:9000'
  ENV['CONCORD_LOCAL_CLIENT_SECRET']        ||= 'abf0a91d-f761-499c-83a6-5816d5428d38'
  ENV['CONCORD_CONCORD_PORTAL_URL']         ||= ''
  ENV['CONCORD_CONCORD_PORTAL_CLIENT_SECRET'] ||= ''

  # Tests User authorization for various actions.
  describe 'abilities' do
    subject  { ability }
    let(:ability) { Ability.new(user) }
    let(:user) { nil }
    let(:locked_activity) do
      la = FactoryGirl.create(:locked_activity)
      la.pages << FactoryGirl.create(:page)
      la.user = FactoryGirl.create(:admin)
      la.save
      la
    end

    context 'when is an administrator' do
      let(:user) { FactoryGirl.build(:admin) }

      it { is_expected.to be_able_to(:manage, :all) }
    end

    context 'when is an author' do
      let (:user) { FactoryGirl.build(:author) }
      let (:other_user) { FactoryGirl.build(:author) }
      let (:page) { FactoryGirl.create(:page) }
      let (:other_page) { FactoryGirl.create(:page) }
      let (:self_activity) { stub_model(LightweightActivity, user_id: user.id, pages: [page]) }
      let (:other_activity) { stub_model(
                                         LightweightActivity,
                                         user_id: 15,
                                         pages: [other_page],
                                         publication_status: 'public'
                                        ) }
      let (:self_sequence) { stub_model(Sequence, user_id: user.id) }
      let (:other_sequence) { stub_model(Sequence, user_id: 15) }
      let (:public_sequence) { stub_model(Sequence, publication_status: "public", user_id: 15) }
      let (:hidden_sequence) { stub_model(Sequence, publication_status: "hidden", user_id: 15) }
      let (:private_sequence) { stub_model(Sequence, publication_status: "private", user_id: 15) }
      let (:archive_sequence) { stub_model(Sequence, publication_status: "archive", user_id: 15) }
      let (:self_glossary) { stub_model(Glossary, user_id: user.id) }
      let (:section) { FactoryGirl.create(:section, :on_page, :with_items, interactive_page: page) }
      let (:plugin) { FactoryGirl.create(:plugin, plugin_scope: self_activity) }
      let (:other_plugin) { FactoryGirl.create(:plugin, plugin_scope: other_activity) }
      let (:interactive) { FactoryGirl.create(:mw_interactive) }

      it { is_expected.to be_able_to(:create, Glossary) }
      it { is_expected.to be_able_to(:duplicate, Glossary) }
      it { is_expected.to be_able_to(:export, Glossary) }
      it { is_expected.to be_able_to(:import, Glossary) }
      it { is_expected.to be_able_to(:manage, self_glossary) }
      it { is_expected.to be_able_to(:read, Glossary) }

      it { is_expected.to be_able_to(:create, InteractivePage) }
      it { is_expected.to be_able_to(:manage, self_activity) }

      it { is_expected.to be_able_to(:create, LightweightActivity) }
      it { is_expected.to be_able_to(:duplicate, other_activity) }
      it { is_expected.not_to be_able_to(:duplicate, locked_activity) }
      it { is_expected.to be_able_to(:export, self_activity) }
      it { is_expected.to be_able_to(:export, other_activity) }
      it { is_expected.not_to be_able_to(:export, locked_activity) }
      it { is_expected.to be_able_to(:import, LightweightActivity) }
      it { is_expected.to be_able_to(:read, other_activity) }
      it { is_expected.not_to be_able_to(:manage, other_activity) }
      it { is_expected.to be_able_to(:manage, self_activity) }
      it { is_expected.not_to be_able_to(:manage, locked_activity) }
      it { is_expected.not_to be_able_to(:manage, other_activity) }

      it { is_expected.to be_able_to(:create, LinkedPageItem) }

      it { is_expected.to be_able_to(:create, PageItem) }
      it { is_expected.to be_able_to(:read, other_activity.pages.first) }

      it { is_expected.to be_able_to(:create, Plugin) }
      it { is_expected.to be_able_to(:manage, plugin) }
      it { is_expected.not_to be_able_to(:manage, other_plugin) }

      it { is_expected.to be_able_to(:create, Sequence) }
      it { is_expected.to be_able_to(:duplicate, public_sequence) }
      it { is_expected.to be_able_to(:duplicate, hidden_sequence) }
      it { is_expected.not_to be_able_to(:duplicate, private_sequence) }
      it { is_expected.not_to be_able_to(:duplicate, archive_sequence) }
      it { is_expected.to be_able_to(:export, self_sequence) }
      it { is_expected.to be_able_to(:export, other_sequence) }
      it { is_expected.to be_able_to(:export, public_sequence) }
      it { is_expected.to be_able_to(:export, hidden_sequence) }
      it { is_expected.to be_able_to(:export, private_sequence) }
      it { is_expected.to be_able_to(:export, archive_sequence) }
      it { is_expected.to be_able_to(:import, Sequence) }
      it { is_expected.to be_able_to(:update, self_sequence) }
      it { is_expected.not_to be_able_to(:update, other_sequence) }
    end

    context 'when is a project admin' do
      before(:each) do
        project.admins = [user]
        project.save!
        project.reload

        locked_activity.project = project
        locked_activity.save!
        locked_activity.reload
      end

      let (:user) { FactoryGirl.build(:user) }
      let (:project) { FactoryGirl.build(:project) }
      let (:other_project) { FactoryGirl.build(:project) }
      let (:page) { FactoryGirl.build(:page) }
      let (:activity) { stub_model(LightweightActivity, user_id: 15, pages: [page], project: project) }
      let (:other_activity) { stub_model(LightweightActivity, user_id: 15, pages: [page], publication_status: 'public') }
      let (:sequence) { stub_model(Sequence, user_id: 15, project: project) }
      let (:public_sequence) { stub_model(Sequence, publication_status: "public", user_id: 15, project: project) }
      let (:hidden_sequence) { stub_model(Sequence, publication_status: "hidden", user_id: 15, project: project) }
      let (:private_sequence) { stub_model(Sequence, publication_status: "private", user_id: 15, project: project) }
      let (:archive_sequence) { stub_model(Sequence, publication_status: "archive", user_id: 15, project: project) }
      let (:glossary) { stub_model(Glossary, user_id: 15, project: project) }
      let (:no_project_glossary) { stub_model(Glossary, user_id: 15) }
      let (:other_project_glossary) { stub_model(Glossary, user_id: 15, project: other_project) }
      let (:section) { FactoryGirl.create(:section, :on_page, :with_items, interactive_page: page) }
      let (:plugin) { FactoryGirl.create(:plugin, plugin_scope: activity) }
      let (:interactive) { FactoryGirl.create(:mw_interactive) }

      it { is_expected.to be_able_to(:create, Glossary) }
      it { is_expected.to be_able_to(:duplicate, glossary) }
      it { is_expected.to be_able_to(:export, glossary) }
      it { is_expected.to be_able_to(:import, glossary) }
      it { is_expected.to be_able_to(:manage, glossary) }
      it { is_expected.not_to be_able_to(:manage, no_project_glossary) }
      it { is_expected.not_to be_able_to(:manage, other_project_glossary) }
      it { is_expected.to be_able_to(:read, glossary) }

      it { is_expected.to be_able_to(:create, InteractivePage) }
      it { is_expected.to be_able_to(:manage, InteractivePage, activity) }

      it { is_expected.to be_able_to(:create, LightweightActivity) }
      it { is_expected.to be_able_to(:duplicate, other_activity) }
      it { is_expected.to be_able_to(:duplicate, locked_activity) }
      it { is_expected.to be_able_to(:export, activity) }
      it { is_expected.to be_able_to(:export, other_activity) }
      it { is_expected.to be_able_to(:export, locked_activity) }
      it { is_expected.to be_able_to(:import, LightweightActivity) }
      it { is_expected.to be_able_to(:read, other_activity) }
      it { is_expected.not_to be_able_to(:manage, other_activity) }
      it { is_expected.to be_able_to(:manage, activity) }
      it { is_expected.to be_able_to(:manage, locked_activity) }
      it { is_expected.not_to be_able_to(:manage, other_activity) }

      it { is_expected.to be_able_to(:create, LinkedPageItem) }

      it { is_expected.to be_able_to(:create, PageItem) }
      it { is_expected.to be_able_to(:read, other_activity.pages.first) }

      it { is_expected.to be_able_to(:create, Plugin) }
      it { is_expected.to be_able_to(:manage, plugin) }

      it { is_expected.to be_able_to(:create, Sequence) }
      it { is_expected.to be_able_to(:duplicate, public_sequence) }
      it { is_expected.to be_able_to(:duplicate, hidden_sequence) }
      it { is_expected.to be_able_to(:duplicate, private_sequence) }
      it { is_expected.to be_able_to(:duplicate, archive_sequence) }
      it { is_expected.to be_able_to(:export, sequence) }
      it { is_expected.to be_able_to(:export, public_sequence) }
      it { is_expected.to be_able_to(:export, hidden_sequence) }
      it { is_expected.to be_able_to(:export, private_sequence) }
      it { is_expected.to be_able_to(:export, archive_sequence) }
      it { is_expected.to be_able_to(:import, Sequence) }
      it { is_expected.to be_able_to(:update, sequence) }
    end

    context 'when is anonymous' do
      let(:other_user) do
        ou = FactoryGirl.build(:author)
        ou.id = 3
        ou.save
        ou
      end
      let(:anon_run) { FactoryGirl.create(:run, user: nil) }
      let(:anon_sequence_run) { FactoryGirl.create(:sequence_run, user: nil) }
      let(:other_run) { FactoryGirl.create(:run, user: other_user) }
      let(:other_sequence_run) { FactoryGirl.create(:sequence_run, user: other_user) }

      it { is_expected.to be_able_to(:access, anon_run) }
      it { is_expected.to be_able_to(:access, anon_sequence_run) }
      it { is_expected.not_to be_able_to(:access, other_run) }
      it { is_expected.not_to be_able_to(:access, other_sequence_run) }
    end

    context 'when is a user' do
      let(:user) do
        u = FactoryGirl.build(:user)
        u.id = 2
        u.save
        u
      end
      let(:other_user) do
        ou = FactoryGirl.build(:author)
        ou.id = 3
        ou.save
        ou
      end
      let(:other_user2) do
        ou = FactoryGirl.build(:author)
        ou.id = 4
        ou.save
        ou
      end
      let(:hidden_activity) do
        act = FactoryGirl.create(:activity)
        act.user = other_user
        act.user_id = other_user.id
        act.pages << FactoryGirl.create(:page)
        act.save
        act
      end
      let(:public_activity) do
        oa = FactoryGirl.create(:public_activity)
        oa.user = other_user
        oa.user_id = other_user.id
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end
      let(:private_activity) do
        oa = FactoryGirl.create(:private_activity)
        oa.user = other_user
        oa.user_id = other_user.id
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end
      let(:archive_activity) do
        oa = FactoryGirl.create(:archive_activity)
        oa.user = other_user
        oa.user_id = other_user.id
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end
      let(:own_activity) do
        oa = FactoryGirl.create(:private_activity)
        oa.user = user
        oa.user_id = user.id
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end
      let(:own_sequence) do
        os = FactoryGirl.create(:sequence_with_activity, publication_status: "private")
        os.user = user
        os.user_id = user.id
        os.save
        os
      end
      let(:archive_sequence) { FactoryGirl.create(:sequence_with_activity, publication_status: "archive") }
      let(:hidden_sequence) { FactoryGirl.create(:sequence_with_activity, publication_status: "hidden") }
      let(:public_sequence) { FactoryGirl.create(:sequence_with_activity, publication_status: "public") }
      let(:private_sequence) { FactoryGirl.create(:sequence_with_activity, publication_status: "private") }
      let(:own_run) { FactoryGirl.create(:run, user: user) }
      let(:anon_run) { FactoryGirl.create(:run, user: nil) }
      let(:other_run) { FactoryGirl.create(:run, user: other_user) }
      let(:own_sequence_run) { FactoryGirl.create(:sequence_run, user: user) }
      let(:own_irs) { FactoryGirl.create(:interactive_run_state, run: own_run) }
      let(:other_irs) { FactoryGirl.create(:interactive_run_state, run: other_run) }
      let(:other_sequence_run) { FactoryGirl.create(:sequence_run, user: other_user) }
      let(:anon_irs) { FactoryGirl.create(:interactive_run_state, run: anon_run) }

      let(:collaboration_activity) { FactoryGirl.create(:activity) }
      let(:follower_run) { FactoryGirl.create(:run, user: user, activity: collaboration_activity) }
      let(:leader_run) { FactoryGirl.create(:run, user: other_user, activity: collaboration_activity) }
      let(:collaboration_run) { FactoryGirl.create(:collaboration_run, user: other_user) }
      let(:collaborating_run) { FactoryGirl.create(:run, user: other_user, collaboration_run: collaboration_run, activity: collaboration_activity) }
      let(:collaboration_irs) { FactoryGirl.create(:interactive_run_state, run: collaborating_run) }

      let(:other_collaboration_activity) { FactoryGirl.create(:activity) }
      let(:other_follower_run) { FactoryGirl.create(:run, user: other_user2, activity: other_collaboration_activity) }
      let(:other_leader_run) { FactoryGirl.create(:run, user: other_user, activity: other_collaboration_activity) }
      let(:other_collaboration_run) { FactoryGirl.create(:collaboration_run, user: other_user2) }
      let(:other_collaborating_run) { FactoryGirl.create(:run, user: other_user, collaboration_run: other_collaboration_run, activity: other_collaboration_activity) }
      let(:other_collaboration_irs) { FactoryGirl.create(:interactive_run_state, run: other_collaborating_run) }

      let(:glossary) { FactoryGirl.create(:glossary, user: other_user) }
      let(:own_glossary) { FactoryGirl.create(:glossary, user: user) }

      it { is_expected.not_to be_able_to(:create, Glossary) }
      it { is_expected.to be_able_to(:update, own_glossary) }
      it { is_expected.not_to be_able_to(:update, glossary) }

      it { is_expected.not_to be_able_to(:create, LightweightActivity) }
      it { is_expected.to be_able_to(:read, archive_activity) }
      it { is_expected.to be_able_to(:read, hidden_activity) }
      it { is_expected.to be_able_to(:read, public_activity) }
      it { is_expected.not_to be_able_to(:read, private_activity) }
      it { is_expected.to be_able_to(:update, own_activity) }
      it { is_expected.not_to be_able_to(:update, public_activity) }

      it { is_expected.not_to be_able_to(:create, InteractivePage) }
      it { is_expected.to be_able_to(:read, archive_activity.pages[0]) }
      it { is_expected.to be_able_to(:read, hidden_activity.pages[0]) }
      it { is_expected.to be_able_to(:read, public_activity.pages[0]) }
      it { is_expected.not_to be_able_to(:read, private_activity.pages[0]) }
      it { is_expected.to be_able_to(:update, own_activity.pages[0]) }
      it { is_expected.not_to be_able_to(:update, public_activity.pages[0]) }

      it { is_expected.not_to be_able_to(:create, Sequence) }
      it { is_expected.to be_able_to(:read, Sequence) }
      it { is_expected.to be_able_to(:read, archive_sequence) }
      it { is_expected.to be_able_to(:read, hidden_sequence) }
      it { is_expected.to be_able_to(:read, public_sequence) }
      it { is_expected.not_to be_able_to(:read, private_sequence) }
      it { is_expected.to be_able_to(:update, own_sequence) }
      it { is_expected.not_to be_able_to(:update, public_sequence) }

      it { is_expected.not_to be_able_to(:manage, User) }

      it { is_expected.to be_able_to(:about, Project) }
      it { is_expected.to be_able_to(:help, Project) }
      it { is_expected.to be_able_to(:contact_us, Project) }

      it { is_expected.to be_able_to(:access, own_run) }
      it { is_expected.not_to be_able_to(:access, other_run) }
      it { is_expected.to be_able_to(:access, own_sequence_run) }
      it { is_expected.not_to be_able_to(:access, other_sequence_run) }

      it { is_expected.to be_able_to(:show, own_irs) }
      it { is_expected.to be_able_to(:update, own_irs) }
      it { is_expected.to be_able_to(:show, anon_irs) }
      it { is_expected.to be_able_to(:update, anon_irs) }
      it { is_expected.not_to be_able_to(:show, other_irs) }
      it { is_expected.not_to be_able_to(:update, other_irs) }

      describe "collaboration interactive run states" do
        before (:each) do
          collaboration_run.runs << leader_run
          collaboration_run.runs << follower_run

          other_collaboration_run.runs << other_leader_run
          other_collaboration_run.runs << other_follower_run
        end

        it { is_expected.to be_able_to(:show, collaboration_irs) }
        it { is_expected.to be_able_to(:update, collaboration_irs) }

        it { is_expected.not_to be_able_to(:show, other_collaboration_irs) }
        it { is_expected.not_to be_able_to(:update, other_collaboration_irs) }
      end
    end
  end

  describe "#find_for_concord_portal_oauth" do
    let(:auth_email)    { "testuser@concord.org" }
    let(:auth_provider) { "portal.concord.org"   }
    let(:auth_uid)      { "23"                   }
    let(:auth_token)    { "xyzzy"                }
    let(:auth_roles)    { []                     }

    let(:auth) do
      auth_obj = double(provider: auth_provider, uid: auth_uid)
      allow(auth_obj).to receive_message_chain(:info, :email).and_return(auth_email)
      allow(auth_obj).to receive_message_chain(:extra, :roles).and_return(auth_roles)
      allow(auth_obj).to receive_message_chain(:credentials, :token).and_return(auth_token)
      auth_obj
    end

    describe "with matching provider and user" do
      it "should return the matching user" do

        expected = FactoryGirl.create(:user)
        authentication = FactoryGirl.create(:authentication,
          {user: expected, provider: auth_provider, uid: auth_uid})

        expect(User.find_for_concord_portal_oauth(auth)).to eq(expected)
      end
    end

    describe "with matching email address and no provider" do
      it "should return the found user" do
        expected = FactoryGirl.create(:user,
          { email: auth_email } )
        expect(User.find_for_concord_portal_oauth(auth)).to eq(expected)
      end
      it "should update the provider and user to match found" do
        expected = FactoryGirl.create(:user,
          { email: auth_email } )
        found = User.find_for_concord_portal_oauth(auth)
        expect(found.email).to    eq(expected.email)
        authentication = found.authentications.first
        expect(authentication.provider).to eq(auth.provider)
        expect(authentication.uid).to      eq(auth.uid)
      end
    end

    describe "with matching email address and different provider" do
      it "should create a new authentication with the provider and uid" do

        expected = FactoryGirl.create(:user,
          { email: auth_email }  )
        authentication = FactoryGirl.create(:authentication,
          {user: expected, provider: 'some other provider', uid: auth_uid})
        found = User.find_for_concord_portal_oauth(auth)
        expect(found.email).to                eq(expected.email)
        expect(found.authentications.size).to eq(2)

        authentication = found.authentications.find_by_provider auth.provider
        expect(authentication).not_to eq(nil)
        expect(authentication.uid).to eq(auth.uid)
      end
    end

    describe "with matching email address and wrong uid" do
      it "should throw an exception" do
        expected = FactoryGirl.create(:user,
          { email: auth_email}  )
        authentication = FactoryGirl.create(:authentication,
          {user: expected, provider: auth_provider, uid: "222"})
        expect { User.find_for_concord_portal_oauth(auth) }.to raise_error(UncaughtThrowError)
      end
    end

    describe '#auth_providers' do
      let(:user) { FactoryGirl.create(:user) }
      let(:run)  { FactoryGirl.create(:run, remote_endpoint: 'http://localhost:9000') }
      let(:auth) { FactoryGirl.create(:authentication, provider: 'concord_portal') }

      it 'should return an array of symbols' do
        expect(user.auth_providers).to eq([])
      end

      it 'should get providers from previous authentications' do
        user.authentications << auth
        expect(user.auth_providers).to include('CONCORD_PORTAL')
      end

      it 'should get providers from previous runs' do
        user.runs << run
        expect(user.auth_providers).to include('LOCAL')
      end
    end
  end

  describe "#has_api_key" do
    let(:existing_api_key) { nil }
    let(:opts) { { api_key: existing_api_key } }
    let(:user) { FactoryGirl.build(:user, opts) }

    it "by default users do not have an api_key" do
      expect(user.api_key).to be_nil
      expect(user.has_api_key).to be false
    end

    describe "Enabling the API key for the user" do

      describe "when the user doesn't already have an api_key" do
        let(:existing_api_key) { nil }
        it "should give them a new api_key" do
          expect(user.api_key).to be_nil
          user.has_api_key = "1"
          expect(user.api_key).not_to be_nil
        end
      end

      describe "when the user already has an api_key" do
        let(:existing_api_key) { "fake_key"}
        it "the api_key for the user should not be changed" do
          expect(user.api_key).to eql "fake_key"
          user.has_api_key = "1"
          expect(user.api_key).to eql "fake_key"
        end
      end

      describe "Disabling the API key for the user" do

        describe "when the user doesn't have an api_key" do
          let(:existing_api_key) { nil }
          it "none should be generated" do
            expect(user.api_key).to be_nil
            user.has_api_key = "0"
            expect(user.api_key).to be_nil
          end
        end

        describe "when the user has an api_key" do
          let(:existing_api_key) { "fake_key"}
          it "the api_key should be deleted" do
            expect(user.api_key).to eql "fake_key"
            user.has_api_key = "0"
            expect(user.api_key).to be_nil
          end
        end
      end

    end

  end

  describe "project_admins and admined_projects" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project1) { FactoryGirl.create(:project) }
    let(:project2) { FactoryGirl.create(:project) }

    it "should be empty by default" do
      project1
      project2

      expect(user.project_admins.length).to be(0)
      expect(user.admined_projects.length).to be(0)

      expect(user.project_admin_of?(nil)).to be(false)
      expect(user.project_admin_of?(project1)).to be(false)
      expect(user.project_admin_of?(project2)).to be(false)
    end

    it "should return an array when set" do
      user.admined_projects = [project1, project2]
      expect(user.project_admins.length).to be(2)
      expect(user.project_admins[0].project.id).to be(project1.id)
      expect(user.project_admins[1].project.id).to be(project2.id)
      expect(user.project_admins[0].user.id).to be(user.id)
      expect(user.project_admins[1].user.id).to be(user.id)

      expect(user.admined_projects.length).to be(2)
      expect(user.admined_projects[0].id).to be(project1.id)
      expect(user.admined_projects[1].id).to be(project2.id)

      expect(user.project_admin_of?(project1)).to be(true)
      expect(user.project_admin_of?(project2)).to be(true)
    end
  end

end
