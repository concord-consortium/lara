require 'spec_helper'

describe Embeddable::LabbookAnswersController do
  before(:each) do
    stub_request(:any, endpoint)
  end

  let(:question) { Embeddable::Labbook.create! }
  let(:answer)   { Embeddable::LabbookAnswer.create!(question: question, run: run) }
  let(:endpoint) { 'http://concord.portal.org' }

  describe '#update' do
    describe 'with a run initiated from remote portal' do
      let(:run) { FactoryGirl.create(:run, remote_endpoint: endpoint) }
      it 'should fire off a web request to update the portal' do
        put 'update', id: answer.id
        assert_requested :post, endpoint
      end
    end
  end

  describe 'with no endpoint defined (not requested from portal)' do
    let(:run) { FactoryGirl.create(:run) }
    it 'should not fire a web request to update the portal' do
      put 'update', id: answer.id
      assert_not_requested :post, endpoint
    end
  end
end
