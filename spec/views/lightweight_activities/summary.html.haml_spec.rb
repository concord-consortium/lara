require 'spec_helper'

describe 'lightweight_activities/summary' do
  # Stub what we need to render the page
  let(:activity)  { stub_model(LightweightActivity, :id => 1, :name => 'Activity Name') }
  let(:mc1) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt one', :question_index => '1', :answer_texts => ['Answer text'], :multi_answer => false) }
  let(:mc2) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt two', :question_index => '2', :answer_texts => ['first answer', 'second answer'], :multi_answer => true) }
  let(:or1) { stub_model(Embeddable::OpenResponseAnswer, :prompt => 'prompt three', :question_index => '3', :answer_text => 'I wrote a bunch of stuff') }
  let(:mc3) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt four', :question_index => '4', :answer_texts => ['This should not show', 'This should show'], :multi_answer => false) }
  let(:or2) { stub_model(Embeddable::OpenResponseAnswer, :prompt => 'prompt five', :question_index => '5', :answer_text => nil) }

  before(:each) do
    assign(:activity, activity)
    assign(:answers, [mc1, mc2, or1, mc3, or2])
  end

  it 'shows print buttons at top and bottom' do
    render
    rendered.should have_css "button.print", :count => 2
  end

  it 'shows the activity title' do
    render
    rendered.should match /Response Summary for Activity Name/
  end

  it 'lists the questions with numbers and prompts' do
    render
    rendered.should have_css "div.prompt", :count => 5
    rendered.should have_css "div.number", :count => 5
    words = ['zero', 'one', 'two', 'three', 'four', 'five']
    (1..5).each do |i|
      rendered.should match /#{i}\./
      rendered.should match /prompt #{words[i]}/
    end
  end

  it 'shows response text with the questions' do
    render
    rendered.should have_css 'div.answer', :count => 5
    # OR answer
    rendered.should match /I wrote a bunch of stuff/
    # MC answer, single
    rendered.should match /Answer text/
    # MC answer, multi
    rendered.should match /first answer/
    rendered.should match /second answer/
  end

  it 'has answer-items for each multiple choice answer' do
    render
    # One for mc1, two for mc2, and one for mc3 even though it has two answer_texts
    rendered.should have_css 'div.answer_item', :count => 4
    rendered.should match /This should show/
    rendered.should_not match /This should not show/
  end
end