require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoicesController do

  # it_should_behave_like 'an embeddable controller'
  describe '#check' do
    before do
      @correct = Embeddable::MultipleChoiceChoice.create!(:choice => 'This is correct', :is_correct => true)
      @incorrect = Embeddable::MultipleChoiceChoice.create!(:choice => 'This is incorrect', :is_correct => false)
      @with_prompt = Embeddable::MultipleChoiceChoice.create!(:choice => 'This is incorrect', :is_correct => false, :prompt => 'Consider what would happen if this was true.')
    end

    it 'redirects HTML requests to the owning page' do
      pending "Choices can't find their pages yet"
      get :check, :id => @correct.id, :format => 'html'
      response.should redirect_to() # TODO: Some page
    end

    it 'returns true for a correct answer' do
      get :check, :id => @correct.id, :format => 'json'
      response.body.should match /"choice":[\w]*true/
    end

    it 'returns false for an incorrect answer' do
      get :check, :id => @incorrect.id, :format => 'json'
      response.body.should match /"choice":[\w]*false/
    end

    it 'returns a custom response if one is configured' do
      get :check, :id => @with_prompt.id, :format => 'json'
      response.body.should match /"prompt":[\w]*"Consider what would happen if this was true."/
    end
  end
end
