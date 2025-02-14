# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  # Name is defined in the LightweightActivity factory
  sequence(:page_sidebar) { |n| Faker::Lorem.sentences(number: 4).join(" ") }
  sequence(:page_text)    { |n| Faker::Lorem.sentences(number: 6).join(" ") }

  factory :page, class: InteractivePage, aliases: [:interactive_page]  do
    name { generate(:name) }
    sidebar { generate(:page_sidebar) }
    show_header { 1 }
    show_sidebar { 1 }
    show_interactive { 1 }
    show_info_assessment { 1 }
    is_hidden { 0 }

    transient do
      interactives { [] }
      embeddables { [] }
    end

    after(:create) do |page,evaluator|
      interactives =  evaluator.interactives || []
      interactives.each do |interactive|
        page.add_interactive interactive
      end

      embeddables =  evaluator.embeddables || []
      embeddables.each do |embeddable|
        page.add_embeddable embeddable
      end
    end

    factory :interactive_page_with_or, aliases: [:page_with_or] do
      name { "page with open response" }
      after(:create) do |page, evaluator|
        page.add_embeddable(FactoryBot.create(:or_embeddable, is_hidden: false))
        # page.page_items  { [ FactoryBot.create(:page_item, :interactive_page => page) ] }
        # FactoryBot.create_list(:page_item, 1, :interactive_page => page)
      end
    end

    factory :interactive_page_with_hidden_or do
      name { "page with hidden open response" }
      after(:create) do |page, evaluator|
        # page.page_items  { [ FactoryBot.create(:page_item, :interactive_page => page) ] }
        page.add_embeddable(FactoryBot.create(:or_embeddable, is_hidden: true))
        # FactoryBot.create_list(:hidden_page_item, 1, :interactive_page => page)
      end
    end

  end
end
