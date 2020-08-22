module Flows
  class SharedContextPipeline
    module DSL
      # @api private
      module Callbacks
        SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@before_all_callbacks' => [],
          '@after_all_callbacks' => [],
          '@before_each_callbacks' => [],
          '@after_each_callbacks' => []
        )

        include SingletonVarsSetup

        attr_reader :before_all_callbacks, :after_all_callbacks, :before_each_callbacks, :after_each_callbacks

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
end
