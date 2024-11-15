FactoryGirl.define do
  factory :labbook, class: Embeddable::Labbook do
    name        { generate(:name) }
    prompt      { generate(:prompt) }
    action_type { Embeddable::Labbook::SNAPSHOT_ACTION }
    is_hidden   { false }
  end
end
