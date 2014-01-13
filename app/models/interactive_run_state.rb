class InteractiveRunState < ActiveRecord::Base
  attr_accessible :interactive, :run, :raw_data

  belongs_to :run
  belongs_to :interactive, :polymorphic => true
end
