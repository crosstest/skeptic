require 'middleware'

module Omnitest
  class Skeptic
    module Spies
      class << self
        attr_reader :spies

        def middleware
          @middleware ||= Middleware::Builder.new
        end

        def spies
          @spies ||= Set.new
        end

        def register_spy(spy)
          spies.add(spy)
          middleware.insert 0, spy, {}
        end

        def observe(scenario, &blk)
          middleware = Middleware::Builder.new
          spies.each do |spy|
            middleware.use spy, Thread.current[:test_env_number]
          end
          middleware.use blk
          middleware.call(scenario)
        end

        def reports
          # Group by type
          all_reports = spies.flat_map do |spy|
            spy.reports.to_a if spy.respond_to? :reports
          end
          all_reports.each_with_object({}) do |(k, v), h|
            (h[k] ||= []) << v
          end
        end
      end
    end
  end
end
