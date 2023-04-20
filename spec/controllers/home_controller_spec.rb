require 'spec_helper'

describe HomeController do

  it_behaves_like "remote duplicate support" do
    let(:user) { FactoryGirl.create(:user) }
    let(:resource) { FactoryGirl.create(:activity) }
    let(:author_url) { "http://authoring.concord.org#{Rails.application.routes.url_helpers.activity_path(resource)}/edit" }
  end

  it_behaves_like "remote duplicate support" do
    let(:project) { FactoryGirl.create(:project) }
    let(:sequence) { FactoryGirl.create(:sequence,
      publication_status: 'public',
      project: project,
      user: user) }
    let(:activity) { FactoryGirl.create(:public_activity) }
    let(:user) { FactoryGirl.create(:user) }
    let(:resource) { FactoryGirl.create(:sequence) }
    let(:author_url) { "http://authoring.concord.org#{Rails.application.routes.url_helpers.sequence_path(resource)}/edit" }
  end

  describe '#home' do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      make_collection_with_rand_modication_time(:public_activity,15)
      make_collection_with_rand_modication_time(:sequence,15,:publication_status => 'public')
      make_collection_with_rand_modication_time(:glossary,15,:user => user)
      sign_in user # sign in so user sees their own glossaries
      get :home
    end

    context "with rendered views" do
      render_views
      it 'sets body class to homepage' do
        get :home
        expect(response.body).to match /<body class="right homepage">/
      end
    end

    describe "The activities listing" do
      subject { assigns(:activities) }

      it "'s activities are of the correct type" do
        subject.each { |s| expect(s).to be_a_kind_of(LightweightActivity)}
      end

      it 'displays at most 10 activities' do
        expect(subject.length).to eq(10) # truncated from 15
      end

      it "'s activites are displayed with the newest first" do
        expect(subject).to be_ordered_by "updated_at_desc"
      end
    end

    describe "The sequences listing" do
      subject { assigns(:sequences) }

      it 'sequences are of the correct type' do
        subject.each { |s| expect(s).to be_a_kind_of(Sequence) }
      end

      it 'displays at most 10 sequences' do
        expect(subject.length).to eq(10) # truncated from 15
      end

      it "'s sequences are displayed with the newest first" do
        expect(subject).to be_ordered_by "updated_at_desc"
      end
    end

    describe "The glossaries listing" do
      subject { assigns(:glossaries) }

      it 'glossaries are of the correct type' do
        subject.each { |s| expect(s).to be_a_kind_of(Glossary) }
      end

      it 'displays at most 10 glossaries' do
        expect(subject.length).to eq(10) # truncated from 15
      end

      it "'s glossaries are displayed with the newest first" do
        expect(subject).to be_ordered_by "updated_at_desc"
      end
    end
  end
end
