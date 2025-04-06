FactoryBot.define do
  factory :xhtml, class: Embeddable::Xhtml do
    name     { generate(:name) }
    content  { generate(:description) }
  end
end

