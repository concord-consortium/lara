# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :sequence do
    title { "MyString" }
    description { "MyText" }
    abstract { "short abstract" }

    factory :sequence_with_activity do
      transient do
        pages_count { 2 }
        activities_count { 2 }
      end
      publication_status { 'public' }
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

  factory :activity_player_sequence, class: Sequence do
    title { "MyString" }
    description { "MyText" }
    abstract { "short abstract" }
  end
end
