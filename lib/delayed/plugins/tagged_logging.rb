module Delayed
  module Plugins
    class TaggedLogging < Delayed::Plugin
      Delayed::Worker.logger = Rails.logger

      callbacks do |lifecycle|
        lifecycle.around(:execute) do |worker, *args, &block|
          if worker.name_prefix
            name = worker.name_prefix.strip
          else
            name = "unknown"
          end
          Rails.logger.tagged "Worker:#{name}" do
            block.call(worker, *args)
          end
        end

        lifecycle.around(:invoke_job) do |job, *args, &block|
          Rails.logger.tagged "Job:#{job.id}" do
            block.call(job, *args)
          end
        end
      end
    end
  end
end