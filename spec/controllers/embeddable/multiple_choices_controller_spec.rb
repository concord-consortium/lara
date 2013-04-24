require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoicesController do

  # it_should_behave_like 'an embeddable controller'
  describe '#check' do
    let (:multiple) { FactoryGirl.create(:mc_embeddable, :custom => true ) }
    let (:correct) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is correct', :is_correct => true, :multiple_choice => multiple) }
    let (:incorrect) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is incorrect', :is_correct => false, :multiple_choice => multiple) }
    let (:with_prompt) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is incorrect', :is_correct => false, :prompt => 'Consider what would happen if this was true.', :multiple_choice => multiple) }

    context 'the choice has an owning page' do
      it 'redirects HTML requests to the owning page' do
        page = FactoryGirl.create(:page)
        page.add_embeddable(multiple)
        get :check, :id => correct.id, :format => 'html'
        response.should redirect_to(interactive_page_path(page))
      end
    end
    
    context 'the choice has no owning page' do
      it 'generates a 500 error for HTML requests' do
        correct
        begin
          get :check, :id => correct.id, :format => 'html'
        rescue ActionView::MissingTemplate
        end
      end
    end

    it 'returns true for a correct answer' do
      correct
      get :check, :id => correct.id, :format => 'json'
      response.body.should match /"choice":[\w]*true/
    end

    it 'returns false for an incorrect answer' do
      incorrect
      get :check, :id => incorrect.id, :format => 'json'
      response.body.should match /"choice":[\w]*false/
    end

    it 'returns a custom response if one is configured' do
      with_prompt
      get :check, :id => with_prompt.id, :format => 'json'
      response.body.should match /"prompt":[\w]*"Consider what would happen if this was true."/
    end
  end
end
