FactoryGirl.define do

  factory :section, class: Section  do

    title { Section::DEFAULT_SECTION_TITLE }
    position 1
    show 1
    interactive_page { FactoryGirl.create(:interactive_page)}
    can_collapse_small 1

  end
end
