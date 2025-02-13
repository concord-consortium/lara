FactoryBot.define do

  factory :section, class: Section do
    title  { Faker::Lorem.sentence(word_count: 3) }
    name  { Faker::Lorem.sentence(word_count: 2) }
    layout { Section::DEFAULT_SECTION_TITLE }
    show   { true }
    can_collapse_small { true }

    trait :with_items do
      after :create do |section|
        3.times do |count|
          embeddable = FactoryBot.create(:or_embeddable)
          section.page_items.create!(
            embeddable: embeddable,
            position: count + 1,
            column: PageItem::COLUMN_SECONDARY
          )
        end
      end
    end

    trait :on_page do
      association :interactive_page
    end
  end

end
