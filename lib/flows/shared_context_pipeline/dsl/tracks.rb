module Flows
  class SharedContextPipeline
    module DSL
      # @api private
      module Tracks
        DEFAULT_ROUTER_DEF = RouterDefinition.new(
          Flows::Result::Ok => :next,
          Flows::Result::Err => :end
        )

        SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@tracks' => TrackList.new
        )

        include SingletonVarsSetup

        attr_reader :tracks

        def step(name, router_def = DEFAULT_ROUTER_DEF, &lambda)
          tracks.add_step(
            Step.new(name: name, lambda: lambda, router_def: router_def)
          )
        end

        def mut_step(name, router_def = DEFAULT_ROUTER_DEF, &lambda)
          tracks.add_step(
            MutationStep.new(name: name, lambda: lambda, router_def: router_def)
          )
        end

        def wrap(name, router_def = DEFAULT_ROUTER_DEF, &tracks_definitions)
          tracks.add_step(
            Wrap.new(method_name: name, router_def: router_def, &tracks_definitions)
          )
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
end
