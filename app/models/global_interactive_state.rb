class GlobalInteractiveState < ActiveRecord::Base
  attr_accessible :raw_data, :run_id

  belongs_to :run
end
