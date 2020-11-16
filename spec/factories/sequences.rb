# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sequence do
    title "MyString"
    description "MyText"
    abstract "short abstract"
    activity_player_only false

    factory :sequence_with_activity do
      ignore do
        pages_count 2
        activities_count 2
      end
      publication_status 'public'
      after(:create) do |sequence, evaluator|
        # has_many
        create_list(
          :activity_with_pages, evaluator.activities_count,
          pages_count: evaluator.pages_count,
          sequences: [sequence]
        )
      end
    end
  end
end
