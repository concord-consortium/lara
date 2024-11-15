# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image_question_answer, class: 'Embeddable::ImageQuestionAnswer' do
    run nil
    answer_text "This is my image answer"
    image_url "http://localhost/foo.png"
    annotated_image_url "http://localhost/annotated-foo.png"
  end
end
