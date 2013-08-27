FactoryGirl.define do
  factory :page_item do |f|
    f.interactive_page { FactoryGirl.create(:interactive_page)}
    f.position 1
    f.embeddable       { FactoryGirl.create(:or_embeddable)}
  end
end