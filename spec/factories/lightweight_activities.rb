# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence(:name) { |n| Faker::Lorem.sentence(word_count: 2)[0..49] }
  sequence(:related) { |n| Faker::Lorem.sentences(number: 4).join(" ") }
  sequence(:description) { |n| Faker::Lorem.sentences(number: 4).join(" ") }

  factory :activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'hidden' }
    related { generate(:related) }
    description { generate(:description) }
    project { nil }
  end

  factory :activity_with_page, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'public' }
    related { generate(:related) }
    description { generate(:description) }
    pages { [FactoryBot.create(:page)] }
  end

  factory :activity_with_pages, class: LightweightActivity do
    transient do
      pages_count { 3 }
    end
    name { generate(:name) }
    publication_status { 'public' }
    related { generate(:related) }
    description { generate(:description) }
    after(:create) do |act, evaluator|
      FactoryBot.create_list(:page, evaluator.pages_count, lightweight_activity: act)
    end
  end

  factory :activity_with_page_and_or, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'public' }
    related { generate(:related) }
    description { generate(:description) }
    pages { [FactoryBot.create(:interactive_page_with_or)] }
  end

  factory :public_activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'public' }
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :archive_activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'archive' }
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :private_activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'private' }
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :locked_activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'public' }
    is_locked { true }
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :activity_player_activity, class: LightweightActivity do
    name { generate(:name) }
    publication_status { 'public' }
    related { generate(:related) }
    description { generate(:description) }
    fixed_width_layout { '1100px' }
  end
end
