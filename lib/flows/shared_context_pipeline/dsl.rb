module Flows
  class SharedContextPipeline
    # @api private
    module DSL
      attr_reader :tracks

      DEFAULT_ROUTER_DEF = RouterDefinition.new(
        Flows::Result::Ok => :next,
        Flows::Result::Err => :end
      )

      Flows::Ext::InheritableSingletonVars::DupStrategy.call(
        self,
        '@tracks' => TrackList.new
      )

      def step(name, router_def = DEFAULT_ROUTER_DEF, &lambda)
        tracks.add_step(name: name, lambda: lambda, router_def: router_def)
      end

      def mut_step(name, router_def = DEFAULT_ROUTER_DEF, &lambda)
        tracks.add_mutation_step(name: name, lambda: lambda, router_def: router_def)
      end

      def track(name, &block)
        track_before = tracks.current_track

        tracks.switch_track(name)
        instance_exec(&block)
        tracks.switch_track(track_before)
      end

      # :reek:UtilityFunction is allowed here
      def routes(routes_def)
        RouterDefinition.new(routes_def)
      end
    end
  end
end
