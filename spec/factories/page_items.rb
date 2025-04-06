FactoryBot.define do
  factory :page_item do |f|
    f.interactive_page { FactoryBot.create(:interactive_page)}
    f.position { 1 }
    f.embeddable       { FactoryBot.create(:or_embeddable)}
  end

  factory :hidden_page_item, class: PageItem do |f|
    f.interactive_page { FactoryBot.create(:interactive_page)}
    f.position { 1 }
    f.embeddable       { FactoryBot.create(:or_embeddable, is_hidden: true)}
  end
end
