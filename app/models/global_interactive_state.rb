class GlobalInteractiveState < ApplicationRecord
  # attr_accessible :raw_data, :run_id

  belongs_to :run
end
