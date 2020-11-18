# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:name) { |n| Faker::Lorem.sentence(2)[0..49] }
  sequence(:related) { |n| Faker::Lorem.sentences(4).join(" ") }
  sequence(:description) { |n| Faker::Lorem.sentences(4).join(" ") }

  factory :activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'hidden'
    related { generate(:related) }
    description { generate(:description) }
    runtime "LARA"
  end

  factory :activity_with_page, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
    pages { [FactoryGirl.create(:page)] }
  end

  factory :activity_with_pages, :class => LightweightActivity do
    ignore do
      pages_count 3
    end
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
    after(:create) do |act, evaluator|
      FactoryGirl.create_list(:page, evaluator.pages_count, lightweight_activity: act)
    end
  end

  factory :activity_with_page_and_or, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
    pages { [FactoryGirl.create(:interactive_page_with_or)] }
  end


  factory :public_activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :locked_activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    is_locked true
    related { generate(:related) }
    description { generate(:description) }
  end

  factory :activity_player_activity, :class => LightweightActivity do
    name { generate(:name) }
    publication_status 'public'
    related { generate(:related) }
    description { generate(:description) }
    runtime "Activity Player"
  end
end
