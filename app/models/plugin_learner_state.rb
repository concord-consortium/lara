
class PluginLearnerState < ApplicationRecord

  class LookupStrategy
    def self.get_lookup_strategy(plugin, run)
      if plugin.shared_learner_state_key.present?
        if run.user
          return SharedStateKeyAndUser.new(plugin, run)
        end
        return SharedStateKeyAndRun.new(plugin, run)
      end
      return PluginAndRun.new(plugin, run)
    end

    def initialize(plugin, run)
      @run = run
      @plugin = plugin
    end

    def opts
      {}
    end

    def find
      PluginLearnerState.where(self.opts).first
    end

    def create
      PluginLearnerState.create(self.opts)
    end

    def find_or_create
      self.find || self.create
    end
  end

  class PluginAndRun < LookupStrategy
    def opts
      {
        plugin_id: @plugin.id,
        run_id: @run.id
      }
    end
  end

  class SharedStateKeyAndRun < LookupStrategy
    def opts
      {
        shared_learner_state_key: @plugin.shared_learner_state_key,
        run_id: @run.id
      }
    end
  end

  class SharedStateKeyAndUser < LookupStrategy
    def opts
      {
        shared_learner_state_key: @plugin.shared_learner_state_key,
        user_id: @run.user.id
      }
    end
  end

  belongs_to :plugin
  belongs_to :run
  belongs_to :user
  belongs_to :shared_plugin,
    class_name: 'Plugin',
    foreign_key: 'shared_learner_state_key',
    primary_key: 'shared_learner_state_key'

  # attr_accessible :shared_learner_state_key, :user_id, :run_id, :plugin_id, :state

  def self.get_lookup_strategy(plugin, run)
    LookupStrategy.get_lookup_strategy(plugin,run)
  end

  def self.find_or_create(plugin, run)
    self.get_lookup_strategy(plugin,run).find_or_create()
  end

end
