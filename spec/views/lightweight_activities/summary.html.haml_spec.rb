require 'spec_helper'

describe 'lightweight_activities/summary' do
  # Stub what we need to render the page
  let(:project) { stub_model(Project,:title => "Title",:logo_lara => "Logo",:url => "Url",:footer => "MyText") }
  let(:activity)  { stub_model(LightweightActivity, :id => 1, :name => 'Activity Name') }
  let(:mc1) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt one', :question_index => '1', :answer_texts => ['Answer text'], :multi_answer => false) }
  let(:mc2) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt two', :question_index => '2', :answer_texts => ['first answer', 'second answer'], :multi_answer => true) }
  let(:or1) { stub_model(Embeddable::OpenResponseAnswer, :prompt => 'prompt three', :question_index => '3', :answer_text => 'I wrote a bunch of stuff') }
  let(:mc3) { stub_model(Embeddable::MultipleChoiceAnswer, :prompt => 'prompt four', :question_index => '4', :answer_texts => ['This should not show', 'This should show'], :multi_answer => false) }
  let(:or2) { stub_model(Embeddable::OpenResponseAnswer, :prompt => 'prompt five', :question_index => '5', :answer_text => nil) }
  let(:image_answer_url) { 'http://foo.com/bar.png' }
  let(:image_answer)  { stub_model(Embeddable::ImageQuestionAnswer,
                                   :drawing_prompt => 'drawing prompt six',
                                   :prompt => 'prompt six',
                                   :question_index => '6',
                                   :answer_text => 'this is my image answer',
                                   :image_url => image_answer_url)}

  before(:each) do
    assign(:project, project)
    assign(:run_key, UUIDTools::UUID.random_create.to_s)
    assign(:activity, activity)
    assign(:answers, [mc1, mc2, or1, mc3, or2, image_answer])
    assign(:project, project)
    assign(:run_key, UUIDTools::UUID.random_create.to_s)
  end

  it 'shows the activity title' do
    render
    expect(rendered).to match /#{activity.name}/
  end

  context 'when a prompt includes HTML tags' do
    let(:or2) { stub_model(Embeddable::OpenResponseAnswer, :prompt => '<p>This<img src="/assets/mw-logo.png" /> is the <em>prompt</em>.</p>', :question_index => '5', :answer_text => nil) }

    it 'strips HTML from the prompts' do
      render
      expect(rendered).to match /This is the prompt\./
    end
  end


  it 'lists the questions with numbers and prompts' do
    render
    expect(rendered).to have_css ".prompt .text", :count => 7 # one additional for the draw_prompt
    expect(rendered).to have_css ".prompt .number", :count => 6
    words = ['zero', 'one', 'two', 'three', 'four', 'five', 'six']
    (1..5).each do |i|
      expect(rendered).to match /#{i}:/
      expect(rendered).to match /prompt #{words[i]}/
    end
  end

  it 'shows response text with the questions' do
    render
    expect(rendered).to have_css 'div.answer', :count => 6
    # OR answer
    expect(rendered).to match /I wrote a bunch of stuff/
    # MC answer, single
    expect(rendered).to match /Answer text/
    # MC answer, multi
    expect(rendered).to match /first answer/
    expect(rendered).to match /second answer/
  end

  it 'has answer-items for each multiple choice answer' do
    render
    # One for mc1, two for mc2, and one for mc3 even though it has two answer_texts
    expect(rendered).to have_css 'div.answer_item', :count => 4
    expect(rendered).to match /This should show/
    expect(rendered).not_to match /This should not show/
  end

  it 'shows image question anwer text, and image url' do
    render
    expect(rendered).to have_css 'div.answer', :count => 6
    expect(rendered).to have_css 'div.image_answer', :count => 1
    expect(rendered).to match /<img[^>]*="#{image_answer_url}"/
  end

end