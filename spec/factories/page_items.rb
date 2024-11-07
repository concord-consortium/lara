FactoryGirl.define do
  factory :page_item do |f|
    f.interactive_page { FactoryGirl.create(:interactive_page)}
    f.position 1
    f.embeddable       { FactoryGirl.create(:or_embeddable)}
  end

  factory :hidden_page_item, class: PageItem do |f|
    f.interactive_page { FactoryGirl.create(:interactive_page)}
    f.position 1
    f.embeddable       { FactoryGirl.create(:or_embeddable, is_hidden: true)}
  end
end
