module Flows
  class SharedContextPipeline
    # @api private
    module DSL
      attr_reader :tracks
      attr_reader :before_all_callbacks
      attr_reader :after_all_callbacks
      attr_reader :before_each_callbacks
      attr_reader :after_each_callbacks

      DEFAULT_ROUTER_DEF = RouterDefinition.new(
        Flows::Result::Ok => :next,
        Flows::Result::Err => :end
      )

      Flows::Ext::InheritableSingletonVars::DupStrategy.call(
        self,
        '@tracks' => TrackList.new,
        '@before_all_callbacks' => [],
        '@after_all_callbacks' => [],
        '@before_each_callbacks' => [],
        '@after_each_callbacks' => []
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

      def before_all(&callback)
        before_all_callbacks << callback
      end

      def after_all(&callback)
        after_all_callbacks << callback
      end

      def before_each(&callback)
        before_each_callbacks << callback
      end

      def after_each(&callback)
        after_each_callbacks << callback
      end
    end
  end
end
