require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoicesController do

  # it_should_behave_like 'an embeddable controller'
  describe '#check' do
    let (:multiple) { FactoryGirl.create(:mc_embeddable, :custom => true ) }
    let (:correct) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is correct', :is_correct => true, :multiple_choice => multiple) }
    let (:incorrect) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is incorrect', :is_correct => false, :prompt => '', :multiple_choice => multiple) }
    let (:with_prompt) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is incorrect', :is_correct => false, :prompt => 'Consider what would happen if this was true.', :multiple_choice => multiple) }
    let (:answer) { FactoryGirl.create(:multiple_choice_answer, :question => multiple) }

    context 'the choice has an owning page' do
      it 'redirects HTML requests to the owning page' do
        page = FactoryGirl.create(:page)
        page.add_embeddable(multiple)
        get :check, :id => answer.id, :format => 'html', :choices => correct.id.to_s
        response.should redirect_to(interactive_page_path(page))
      end
    end
    
    context 'the choice has no owning page' do
      it 'generates a 500 error for HTML requests' do
        correct
        begin
          get :check, :id => answer.id, :format => 'html', :choices => correct.id.to_s
        rescue ActionView::MissingTemplate
        end
      end
    end

    context 'when there is only one answer' do
      it 'returns true for a correct answer' do
        correct
        get :check, :id => answer.id, :format => 'json', :choices => correct.id.to_s
        response.body.should match /"choice":[\w]*true/
      end

      it 'returns false for an incorrect answer' do
        incorrect
        get :check, :id => answer.id, :format => 'json', :choices => incorrect.id.to_s
        response.body.should match /"choice":[\w]*false/
      end

      it 'returns a custom response if one is configured' do
        with_prompt
        get :check, :id => answer.id, :format => 'json', :choices => with_prompt.id.to_s
        response.body.should match /"prompt":[\w]*"Consider what would happen if this was true."/
      end
    end

    context 'when there are multiple answers' do
      let (:also_correct) { FactoryGirl.create(:mcc_embeddable, :choice => 'This is correct, too', :is_correct => true, :multiple_choice => multiple) }

      before(:each) do
        multiple.multi_answer = true
        multiple.save
      end

      it 'returns no-answer response if no answers are submitted' do
        # This shouldn't happen on the client end, but we should be ready anyway
        get :check, :id => answer.id, :format => 'json', :choices => nil
        response.body.should match /Please select an answer before checking./
      end

      it 'returns concatenated incorrect text if any submitted answers are incorrect' do
        get :check, :id => answer.id, :format => 'json', :choices => incorrect.id.to_s
        response.body.should match /'#{incorrect.choice}' is incorrect/
      end

      it 'returns concatenated custom responses if incorrect answers have custom responses configured' do
        get :check, :id => answer.id, :format => 'json', :choices => "#{incorrect.id},#{with_prompt.id}"
        response.body.should match /'#{incorrect.choice}' is incorrect/
        response.body.should match /Consider what would happen if this was true./
      end

      it 'returns incomplete response text if submitted answers are correct but incomplete' do
        also_correct
        get :check, :id => answer.id, :format => 'json', :choices => correct.id.to_s
        response.body.should match /You're on the right track, but you didn't select all the right answers yet./
      end

      it 'returns true if submitted answers are all correct and complete' do
        also_correct
        get :check, :id => answer.id, :format => 'json', :choices => "#{correct.id},#{also_correct.id}"
        response.body.should match /"choice":[\w]*true/
      end
    end
  end
end
