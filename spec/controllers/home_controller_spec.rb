require 'spec_helper'

describe HomeController do

  describe '#home' do
    before(:each) do
      make_collection_with_rand_modication_time(:public_activity,15)
      make_collection_with_rand_modication_time(:sequence,15,:publication_status => 'public')
      get :home
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
  end
end
