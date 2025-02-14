FactoryBot.define do
  factory :linked_page_item do |f|
    f.primary { FactoryBot.create(:page_item)}
    f.secondary { FactoryBot.create(:page_item)}
  end
end
