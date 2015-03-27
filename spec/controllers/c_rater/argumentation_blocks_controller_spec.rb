require 'spec_helper'

describe CRater::ArgumentationBlocksController do
  let(:user) { FactoryGirl.create(:author) }
  let(:act)  { FactoryGirl.create(:activity_with_page, user: user) }
  let(:page) { act.pages.first }
  let(:prev_page) { 'http://prev.page.com' }

  before(:each) do
    sign_in user
    @request.env['HTTP_REFERER'] = prev_page
  end

  describe '#create_embeddables' do
    it 'should create argumentation block embeddables' do
      post :create_embeddables, page_id: page.id
      expect(page.embeddables.length).to eql(4)
      expect(response).to redirect_to(prev_page)
    end
  end

  describe '#remove_embeddables' do
    let (:open_response1) { FactoryGirl.create(:open_response) }
    let (:open_response2) { FactoryGirl.create(:open_response) }
    before(:each) do
      page.add_embeddable(open_response1)
      page.add_embeddable(open_response1, nil, CRater::ARG_SECTION_NAME)
    end
    it 'should remove *only* argumentation block embeddables' do
      post :remove_embeddables, page_id: page.id
      expect(page.embeddables.length).to eql(1)
      expect(response).to redirect_to(prev_page)
    end
  end
end
