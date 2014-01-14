class InteractiveRunState < ActiveRecord::Base
  attr_accessible :interactive_id, :interactive_type, :run_id, :raw_data

  belongs_to :run
  belongs_to :interactive, :polymorphic => true

  def self.by_run_and_interactive(run,interactive)
    opts = {
      interactive_id: interactive.id,
      interactive_type: interactive.class.name,
      run_id: run.id
    }
    results = self.where(opts).first
    if results.nil?
      results = self.create(opts)
    end
    return results
  end
end
