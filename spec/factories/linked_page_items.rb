FactoryGirl.define do
  factory :linked_page_item do |f|
    f.primary { FactoryGirl.create(:page_item)}
    f.secondary { FactoryGirl.create(:page_item)}
  end
end
